# Scripting — A Preview

This is a pointer, not a tutorial. Full depth — writing scripts, the
`GhidraScript` API, headless scripting, the Eclipse/GhidraDev workflow — is
covered in module `05-automation-scripting`. What follows is just enough to
recognize the feature when you see it.

## The Script Manager

`Window → Script Manager` (no default shortcut) opens a browsable,
categorized table of every Ghidra script available to the tool. Unlike a
conventional Ghidra plugin, a script needs no external IDE or build step —
edit it, save, and rerun immediately from inside Ghidra. Rerunning the
currently-open script uses **Ctrl+Shift+R**.

Each script can declare metadata in header comments that wires it into the
UI without any extra registration step:

- `@category` — where it sits in the Script Manager's category tree, and
  under the tool's `Scripts` menu if enabled there.
- `@keybinding` — a shortcut to run it directly, once enabled ("In Tool"
  checkbox in the Script Manager table).
- `@menupath` — an explicit menu location, instead of the default `Scripts`
  submenu.
- `@toolbar` — adds a top-level toolbar button to run it.

Source:
`Ghidra/Features/Base/src/main/help/help/topics/GhidraScriptMgrPlugin/GhidraScriptMgrPlugin.htm`;
shortcut confirmed in `GhidraDocs/CheatSheet.html` ("Rerun Script —
Ctrl+Shift+R", "Script Manager — Window → Script Manager", no shortcut
listed for opening the window itself).

## Where this fits

Everything in this module so far — retyping data, fixing signatures,
tracing references, applying FID/Version Tracking results — is exactly the
kind of repetitive, cursor-at-an-address work a `GhidraScript` subclass can
automate across many functions or many binaries at once (including
headlessly, via `analyzeHeadless` — see 00-quickstart/01 for the pointer to
that tool). That's the subject of `05-automation-scripting`.

---

**Self-check:** you want a script to be runnable with one keypress without
digging through the Scripts menu each time — which header metadata field do
you set? → `@keybinding`.
