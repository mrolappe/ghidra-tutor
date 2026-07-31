# Cross-References, Bookmarks, Search

## Cross-references (XRefs)

Two different things share the "xref" name in Ghidra:

- The **`XREF[n]:`** text inline in the Listing at a referenced location is
  just a display of references already recorded in the program database —
  not a live search. Double-click it (or `[more]` if there are several) to
  see the full list.
- **"Show References To..."** (right-click → References → Show References
  to `<item>`) opens the **Location References Dialog**, which actively
  searches for references to whatever's under the cursor — broader than
  what's already recorded. Source code binds this to **Ctrl+Shift+F**, though
  the official printed cheat sheet doesn't list a shortcut for it — if
  Ctrl+Shift+F doesn't fire on your install, use the right-click path and
  check `Edit → Tool Options → Key Bindings`.

## Bookmarks

Five types, color-coded in the Marker/Navigation margins: **Note** (you,
purple), **Info** (a plugin, cyan), **Analysis** (Auto-Analysis, orange),
**Error** (disassembler/Auto-Analysis flagging something unexpected, red),
**Unknown** (magenta).

- **Create one**: right-click at an address in the Listing → **Bookmark** →
  Note Bookmark dialog (address pre-filled; Category/Description optional).
  No default keyboard shortcut ships for creating a bookmark — right-click is
  the way.
- **Bookmarks window** (every bookmark in the program — type, category,
  description, address; click a row to jump there): `Window → Bookmarks`,
  shortcut **Ctrl+B**.
- **Next Bookmark** (step through bookmarks in the Listing): **Ctrl+Alt+B**.

## Search

- **Search → Program Text** (**Ctrl+Shift+E**): two modes — a fast Program
  Database Search (searches the underlying database) and a slower Listing
  Display Search (matches against what's actually rendered on screen).
- **Search → Memory** (**S**): searches raw bytes for a value/pattern, in a
  selectable format (e.g. Hex).
- **Search → For ...**: specialized searches — Matching Instructions, Address
  Tables, Direct References, Instruction Patterns, Scalars, Strings — each
  opens its own results dialog.

---

**Self-check:** you want to find every place in the binary that calls a
particular function, including references Ghidra hasn't recorded yet —
XRef display or "Show References To"? → "Show References To" — it actively
searches, the inline `XREF[n]:` display only shows what's already recorded.
