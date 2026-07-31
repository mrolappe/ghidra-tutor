# Decompiler Tuning: Calling Conventions & Function Signatures

The Decompiler's C-like output is only as good as the function signature
(name, calling convention, return type, parameters) it's working from. Most
"the Decompiler got this wrong" problems trace back to one of these two
knobs.

## Function signature anatomy

A function's signature consists of its **name**, **calling convention**,
**return data type** (with storage), and ordered **parameters** (each with a
data type and storage). Optional attributes ride alongside it: **Varargs**,
**No Return** (calls to it don't fall through — helps disassembly avoid
treating whatever follows a call as more code), **Inline**, **Custom
Storage** (explicit return/parameter storage instead of storage computed
from the calling convention), and **Call Fixup** (a predefined snippet,
defined in the program's `.cspec`, that simplifies the semantic effect of
calling a well-known function).

## Editing a function's signature

Place the cursor on a function's signature (Listing or Decompiler), right
click → **Edit Function...** — default shortcut **F** — opens the **Function
Editor Dialog**. Fields:

- **Function Signature** field at the top — shows/lets you type the whole
  signature directly, but the parser is limited (no templated types, and it
  only knows datatypes already used in the program or in open archives); use
  the structured controls below it for anything non-trivial.
- **Calling Convention** — a combobox of the conventions defined by the
  program's active compiler specification (`.cspec`). Changing it has no
  effect on parameter/return storage if Custom Storage is checked.
- **Function Attributes** — Varargs, In Line, No Return, Use Custom Storage
  checkboxes.
- **Parameters/Return Type table** — Add/Remove/Up/Down a parameter; click a
  Datatype cell to open the Data Type Chooser; Name is editable in place
  (the return row's name is fixed as `<RETURN>`); if Custom Storage is on,
  the Storage cell opens a parameter-storage editor, otherwise storage is
  shown as computed, tagged `(auto)` for hidden auto-parameters (e.g. a
  `this` pointer forced by `__thiscall`) or `(ptr)` for forced-indirect
  storage.
- **Call Fixup** — combobox of Call-Fixups defined in the `.cspec`.
- **Commit all return/parameter details** — a checkbox that controls whether
  the *full* return+parameter set (including datatypes and custom storage)
  gets written back. It auto-enables whenever a change requires a full
  commit to be preserved (using custom storage, or changing a return/param
  datatype). This matters because a full commit stamps the signature as
  `USER_DEFINED` (see Signature Source below), locking it against being
  silently overwritten by later analysis.

Source:
`Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/function/EditFunctionAction.java`
— `KeyStroke.getKeyStroke(KeyEvent.VK_F, 0)` for the Edit Function action
itself.

## Calling conventions

The list you see in the Calling Convention combobox is defined entirely by
the program's compiler specification (`.cspec` file, chosen at import time
via the Language ID) — it's not a fixed global list. For example, the
Windows x86 spec (`x86win.cspec`) defines `__stdcall`, `__cdecl`,
`__fastcall`, and `__thiscall`; the Windows x86-64 spec (`x86-64-win.cspec`)
defines `__fastcall` (used as its *default* prototype — this is Ghidra's
internal name for the Microsoft x64 calling convention, not the 32-bit
fastcall you might expect) and `__thiscall`. Don't assume convention names
are portable between architectures — always check what the active `.cspec`
actually offers.

Getting the calling convention right matters even when you don't touch
anything else: it changes how the Decompiler infers *implicit* parameters
(e.g. a `this` pointer under `__thiscall`) and how many stack bytes a
function purges on return, which cascades into every caller's stack
balance and apparent argument count.

Sources: `Ghidra/Processors/x86/data/languages/x86win.cspec` (`<prototype
name="...">` entries) and `x86-64-win.cspec` (`<default_proto><prototype
name="__fastcall" .../>`); help topic
`Ghidra/Features/Base/src/main/help/help/topics/FunctionPlugin/Variables.htm`
("Calling Convention" field description).

## Signature Source — how "locked in" a signature is

Every function signature carries a **Source Type** with a priority, used to
decide whether later analysis is allowed to overwrite it:

| Source Type | Priority | Typical origin |
|---|---|---|
| `DEFAULT` | 1 (lowest) | dynamically produced content |
| `ANALYSIS` | 2 | Auto Analysis (e.g. Decompiler Parameter ID) |
| `AI` | 2 | AI-assisted suggestions |
| `IMPORTED` | 3 | debug info / import formats (e.g. PDB) |
| `USER_DEFINED` | 4 (highest) | you, editing by hand |

A full commit from the Function Editor dialog (see above) sets
`USER_DEFINED`, which is why it's the one edit that survives a re-run of
auto-analysis. The **Signature Source** field is available as a Function
Listing Field if you want to watch this state per-function.

Source:
`Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/symbol/SourceType.java`.

## Overriding a signature at one call site

Sometimes the *function itself* is right but a specific *call* to it needs a
different prototype interpretation (e.g. a function pointer typed generically
but called through a specific signature at this one call site). In the
Decompiler, right-click a call → **Override Signature** lets you set a
call-site-local signature without touching the called function's real
definition; **Edit Signature Override** edits an override already placed;
both open the same Edit Function Signature-style dialog. Ghidra explicitly
warns that for *direct* calls it's usually better to fix the prototype on
the function itself — local overrides are for the cases where you can't
(indirect/computed calls, or a function that's genuinely called differently
in different places).

Sources:
`Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/OverridePrototypeAction.java`
(action name "Override Signature", popup menu `Decompile → Override
Signature`, no default keybinding) and
`.../EditPrototypeOverrideAction.java` ("Edit Signature Override").

## Committing what the Decompiler inferred

If the Decompiler's own analysis (not you) proposed good locals/parameters,
you can promote that straight to `USER_DEFINED` without retyping anything:
in the Decompiler, right-click → **Commit Params/Return** (shortcut **P**)
commits the current parameter list and return type; **Commit Local Names**
(no default shortcut) commits local variable names only.

Source:
`Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/CommitParamsAction.java`
— `KeyStroke.getKeyStroke(KeyEvent.VK_P, 0)`.

---

**Self-check:** the Decompiler shows a function taking one fewer argument
than you know it does, and stack balance looks off in every caller — what's
the first thing to check before hand-editing parameters? → The function's
**calling convention** — a wrong convention miscomputes implicit parameters
and stack purge, which is exactly this symptom.
