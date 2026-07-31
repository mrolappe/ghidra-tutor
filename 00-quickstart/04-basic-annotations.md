# Basic Annotations

Ghidra's own decompiled/disassembled output is a starting point, not a
finished artifact — renaming, retyping, and commenting as you go is most of
what turns "raw output" into something you can actually read six months
later.

## Renaming

One shortcut covers labels, functions, and variables: **L**.

- **Listing**, cursor on a label field: `L` opens Edit Label (same dialog
  adds a label if there isn't one yet — the action name flips to "Add
  Label").
- **Decompiler**, cursor on a function name: `L` → Rename Function.
- **Decompiler**, cursor on a local, global, or struct-field token: `L` →
  Rename Variable (separate actions under the hood, same shortcut).

## Retyping

Two different shortcuts depending on which view you're in:

- **Decompiler**: **Ctrl+L** retypes a local, global, struct field, or a
  function's return type.
- **Listing**: **T** opens "Choose Data Type" to define/retype a data item.

Related and worth knowing: **B** cycles integer width (byte → word → dword →
qword), **F** cycles float/double, **'** (apostrophe) cycles char → string →
unicode — quick retypes without opening a dialog at all.

## Comments

One shortcut, contextual: **`;`** opens the Set Comment(s) dialog, defaulting
to whichever comment type matches the field under the cursor. Delete a
comment with **Del** while the cursor is on it.

Five comment types exist (same dialog, different tabs — or right-click →
Comments → Set... for a specific one):

| Type | Shown |
|---|---|
| EOL | right of the instruction/data |
| Pre | above the instruction |
| Post | below the instruction |
| Plate | block header above instruction/function, auto-wrapped in `*`s — the "banner" look above functions |
| Repeatable | like EOL, but also shown at every reference site pointing here (if that site has no comment of its own) |

Plate comments are the natural place for a function-level summary; EOL for
"why this specific line"; Repeatable is handy for documenting a helper once
and having that documentation follow it to every call site.

---

**Self-check:** you write a comment explaining what a helper function does,
and want that explanation to show up at every place that calls it, not just
at the function itself — which comment type? → Repeatable.
