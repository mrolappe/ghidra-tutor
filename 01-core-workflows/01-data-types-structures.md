# Data Types & Structures

Ghidra tracks three kinds of data type: **Built-in** (byte, word, string, …
— implemented directly in Java, not editable), **user-defined** (Structures,
Unions, Enums, Typedefs — editable, the ones you create), and **derived**
(Pointers and Arrays — created/deleted as needed, named after their base
type). All of them live in the **Data Type Manager** (`Window → Data Type
Manager`, no default shortcut) alongside the program's own data types.

## Creating a struct, union, enum, or function definition

Right-click the category (folder) in the Data Type Manager tree where the
new type should live, then choose **New → Structure**, **New → Union**,
**New → Enum**, or **New → Function Definition**. Each opens the matching
editor: the Structure Editor for structs/unions, the Enum Editor for enums,
the Edit Function Signature dialog for function definitions. No default
shortcut is bound to these — they're tree-context menu items only.

Structures can also be created directly from a Listing selection of
undefined/defined bytes: select the bytes, **Shift+[** (right-click → Data
→ Create Structure) turns the selection into a new structure in one step.

### Structure / Union Editor

The editor's component table lists each field's offset, length, mnemonic,
data type, name, and comment. Useful actions on the toolbar: **Apply
Changes** (writes the edit back to the program/archive — if the type is
already applied to data in the program, every instance updates, which can
change the size/layout of existing data items), **Undo/Redo Change** (an
editor-local undo stack, separate from the program's), and **Show In Data
Type Manager**. Edits to Name/Description/Size etc. must be committed
(**Enter**, or change focus) or reverted (**Escape**) before other actions
are available. The editor also renders a bit-level view of the layout,
useful for checking bitfield placement (byte order is reversed for
little-endian organizations so a bitfield still reads as a contiguous bit
range).

### Enum Editor

A table of name/value/comment rows. **F2** or double-click a cell to edit
it; **Tab**/**Shift+Tab**/**Up**/**Down** navigate between cells while
editing. The **Size** field (a dropdown) controls how many bytes the enum
occupies when applied — if the Decompiler doesn't show what you expect after
applying an enum, check this first. A toolbar toggle switches the value
column between hex and decimal display.

Selecting two or more existing enums and running **Create Enum from
Selection** merges them into one new enum (asks for a name); if the same
value appears more than once across the source enums, only the first is kept
active but all names survive as a documenting comment.

## Typedefs and pointers

Right-click an existing data type → **New Typedef on `<Name>`** creates a
typedef of that type in the same category — the fastest path. Alternatively,
**New Typedef...** opens a dialog to name the typedef and pick its base type
from anywhere, including any folder. A typedef built on a Pointer base type
supports extra **Pointer-Typedef Settings** (e.g. an address-space
qualifier, or an offset) that influence how the Decompiler interprets that
pointer; if unnamed, such a typedef renders as an "auto-typedef" like
`char * __((space(ram)))`.

Right-click a data type → **New Pointer to `<Name>`** creates a pointer to
it (always created in the same category as the base type — or the active
program's root category, if the base type came from the read-only Built-in
archive).

## Applying, renaming, editing, deleting

- **Apply**: drag a data type from the tree onto a Listing location, or use
  it from the type-chooser dialogs described in the [decompiler-tuning
  guide](02-decompiler-tuning.md). Applying a type from an archive copies it
  into the program and associates the archive so it auto-opens with the
  program from then on.
- **Rename**: right-click → Rename, edit in place.
- **Edit**: double-click the node, or right-click → Edit (structs/unions →
  Structure Editor, enums → Enum Editor; typedefs and Built-ins aren't
  editable). Global shortcut from anywhere in the tool: **Ctrl+Shift+D**
  opens a Data Type Chooser to pick a type to edit.
- **Delete**: right-click → Delete (confirmation required — not undoable
  unless the type lives in the program's own archive).

## Data Type Archives

Archives bundle data types for reuse across programs, projects, and users.
Two user-creatable kinds, both managed from the Data Type Manager's local
menu:

| Kind | Extension/location | Notes |
|---|---|---|
| **File Archive** | `.gdt` file, anywhere on disk | Opened read-only by default, can be opened for editing; only one editor at a time. `New File Archive...` / `Open File Archive...`. |
| **Project Archive** | inside the Ghidra project tree | Versioned and shareable like a program, in a multi-user repository. `New Project Archive...` / `Open Project Archive...`. Dragging a `.gdt` file onto the Project Window also creates a project archive populated from it. |

There's also the always-available **Built-in** archive (the primitive types
compiled into Ghidra — not editable; if you create a new type without
choosing a category, it lands here by default only in the sense that its
root category is used).

When a data type resolved from an archive is copied into a program (or
another archive), Ghidra tags it with a **Source Archive** reference so it
can track drift. The tree shows this as `DataTypeName (SourceArchiveName)`.
Three sync actions live on an archive's popup menu:

- **Update Datatypes From** `<archive>` — pull changes made in the source
  archive into the local copy (Update Data Types dialog; rows flagged
  `UPDATE` or `CONFLICT`).
- **Commit Datatypes To** `<archive>` — push local changes back to the
  source archive (Commit Data Types dialog; rows flagged `COMMIT`,
  `CONFLICT`, or `ORPHAN` for types deleted upstream but still present
  locally).
- **Revert Datatypes From** `<archive>` — discard local changes, reverting
  to the source archive's version.
- **Disassociate Datatypes From** `<archive>` — break the source-archive
  link entirely for selected types (their history of changes is dropped,
  but the type itself stays).

An archive can optionally be assigned a specific processor
**Architecture**/Data Organization while open for editing — recommended
when the archive targets one specific compiler/processor, since primitive
sizing, alignment, and struct packing all derive from it.

## Importing types from a C header

`File → Parse C Source...` opens the C-Parser dialog: pick or build a parse
configuration (an ordered list of header files plus `-I`/`-D` options,
saveable as `.prf`), and it extracts structs, enums, typedefs, and function
signatures from the headers into the current program or a new/existing data
type archive. It runs a real C-preprocessor pass first (writes a debug dump
to `CParserPlugin.out` in your home directory — useful when parsing fails)
then parses the expanded output. As a bonus, any `#define` with an integer
value becomes an **Equate** in the archive — handy for turning magic numbers
like error codes into named constants later.

---

**Self-check:** you've defined a struct in a File Archive and want your
teammate's changes (made independently in the same archive) folded into your
program's copy of that struct — which action do you run? → **Update
Datatypes From** `<archive>` (not Commit — that pushes your changes the
other direction).
