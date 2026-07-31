# Script Manager & the Java API

`01-core-workflows/06-scripting-outlook.md` already introduced the Script
Manager (`Window → Script Manager`) and its four metadata tags. This picks
up from there: what a script actually is, what API it has access to, and
how to develop one in something better than the built-in editor.

## A script is a `GhidraScript` subclass

Every script — Java, Jython, or PyGhidra — implements one method:

```java
public class MyClassScript extends GhidraScript {
    public void run() throws Exception {
        println("hello class");
    }
}
```

No `main()`, no wiring into a menu, no plugin registration. Save the file
into a script directory (default: `<home>/ghidra_scripts`), hit Refresh in
the Script Manager if it doesn't show up automatically, and Run. Metadata
comments (`@category`, `@keybinding`, `@menupath`, `@toolbar`) at the top of
the file — before any code — control how it surfaces in the UI; none are
required.

## Script state — what's already in scope

`GhidraScript` exposes the current tool state as fields, no lookup needed:

| Field | What it is |
|---|---|
| `currentProgram` | the program open when the script ran |
| `currentAddress` | cursor location |
| `currentLocation` | the full `ProgramLocation` at the cursor |
| `currentSelection` | current Listing selection, or `null` |
| `currentHighlight` | current highlight, or `null` |
| `state` | the script's `GhidraState` — lets a script pass values to another script it calls via `runScript()` |
| `monitor` | a `TaskMonitor` — report progress, check `monitor.isCancelled()` in loops so a long script stays cancelable |

## Two API surfaces: Flat vs. Program

`GhidraScript` itself *is* the "Flat API" — one class with method families
grouped by verb prefix:

```java
public abstract class GhidraScript {
    // ask...()    — prompt the user (or read a headless .properties value)
    // create...()  find...()  get...()  remove...()  set...()  to...()
    // runScript()  — invoke another script, sharing (or not) its state
}
```

It's deliberately broad-but-shallow and kept source-compatible release to
release — the safe default for script code. Below it sits the full
object-oriented **Program API** (`Program`, `Listing`, `Function`,
`Instruction`, `Data`, `Memory`, `SymbolTable`, `ReferenceManager`, ...) —
everything the Flat API's `get...()` methods hand back is drawn from this
tree, and reaching into it directly is unavoidable for anything the Flat
API doesn't cover. It's also the layer that *can* change shape across
Ghidra versions, unlike the Flat API's stability guarantee.

## Developing in Eclipse: GhidraDev

The built-in Script Manager editor is fine for a ten-line script; for
anything longer, install the **GhidraDev** Eclipse plugin — ships at
`<GhidraInstallDir>/Extensions/Eclipse/GhidraDev/GhidraDev-<version>.zip`
and installs into Eclipse manually or via the Script Manager's "Edit Script
with Eclipse" button, which offers to point Ghidra at your Eclipse install
the first time you use it.

What it buys you: a proper Ghidra Script Project (correct classpath against
the Ghidra jars, code completion, `Ctrl+Shift+T` open-type,
`Ctrl+Shift+O` organize-imports, `F3` navigate-to-definition, `F4` type
hierarchy, breakpoints and full step-through debugging — including
stepping *into* Ghidra's own API code, not just your script). One thing
doesn't change: **scripts still only run from the Script Manager**, in
Ghidra itself — Eclipse is purely an editor/debugger front end, not an
alternate execution path. Editing outside the Script Manager (including in
Eclipse) means hitting Refresh in the Script Manager before a new or
renamed script shows up.

## Getting help without leaving the tool

The Script Manager's **Help** button opens the Javadoc for `GhidraScript`
directly — and from there, the rest of the Ghidra API. Faster than
searching online for a method signature you half-remember.

---

**Self-check:** you're extending a `GhidraScript` and want to inspect the
full `Function` object for the one under the cursor, not just what
`getFunctionContaining(currentAddress)` (a Flat API method) hands back —
which layer are you now working in, and what's the tradeoff versus staying
in the Flat API? → The Program API (the `Function`/`Listing`/... object
tree) — more capability, but no cross-version stability guarantee, unlike
the Flat API.
