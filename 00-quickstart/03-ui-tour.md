# UI Tour

These five views cover the everyday CodeBrowser workflow. Most open via the
`Window` menu (or a toolbar icon); the Listing is always present.

## Listing

The main disassembly view — address / bytes / mnemonic / operand / comment /
label columns, one row per code unit. It's the default center view in
CodeBrowser; there's no separate "open" step.

## Decompiler

A synthesized, interactive C-like rendering of the function under the
cursor, kept in sync with the Listing — click a C expression to highlight
the corresponding assembly, and vice versa.

Open: toolbar icon or `Window → Decompile: <function name>`. Shortcut:
**Ctrl+E**.

## Symbol Tree

A hierarchical view of the program's symbols: Externals / Functions / Labels
/ Classes / Namespaces, rooted at the Global namespace.

Open: toolbar icon or `Window → Symbol Tree`.

## Data Type Manager

Browse, organize (in folder-like categories), and apply data types. Covers
built-in types (byte, word, string, ... — not editable), types you define
(Structures, Unions, Enums, Typedefs), and derived types (Pointers, Arrays).
Also where data type archives shared across programs/projects live.

Open: `Window → Data Type Manager`.

## Function Graph

A graph view of the function at the cursor: each vertex is a basic block
(header + mini-listing), edges are control flow. Has a Primary View and a
Satellite (overview) view.

Open: `Window → Function Graph`. **Ctrl+Space** toggles between Listing and
Function Graph for the current function (rebindable in tool options).

---

**Self-check:** you renamed a variable in the Decompiler and want to confirm
it took effect in the raw disassembly too — which view do you check, and why
does it show up there at all? → The Listing; a Decompiler variable name is
backed by the same underlying symbol, so the two views share it.
