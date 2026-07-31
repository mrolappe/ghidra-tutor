# Shortcut Cheatsheet

Covers everything from this module. Source: Ghidra's own `CheatSheet.html`
(12.1.2), cross-checked against source-code key bindings — rows marked
*source-verified* are confirmed in code even though the printed cheat sheet
omits them. An interactive, searchable version of this table comes in
Phase 2.

| Action | Context | Shortcut | Menu / path |
|---|---|---|---|
| New Project | — | Ctrl+N | File → New Project |
| Open Project | — | Ctrl+O | File → Open Project |
| Close Project | — | Ctrl+W | File → Close Project |
| Save Project | — | Ctrl+S | File → Save Project |
| Import File | — | I | File → Import File |
| Export Program | — | O | File → Export Program |
| Open File System | — | Ctrl+I | File → Open File System |
| Ghidra Help (context) | hover on item | F1 | Help → Contents |
| Set Key Binding | hover on action | F4 | — |
| Key Bindings editor | — | — | Edit → Tool Options → Key Bindings |
| Undo | — | Ctrl+Z | Edit → Undo |
| Redo | — | Ctrl+Shift+Z | Edit → Redo |
| Save Program | — | Ctrl+S | File → Save `<program name>` |
| Disassemble | — | D | right-click → Disassemble |
| Clear Code/Data | — | C | right-click → Clear Code Bytes |
| Add Label | address field | L | right-click → Add Label |
| Edit/Rename Label | label field | L | right-click → Edit Label |
| Rename Function | function name field | L | right-click → Function → Rename Function |
| Remove Label | label field | Del | right-click → Remove Label |
| Remove Function | function name field | Del | right-click → Function → Delete Function |
| Define / Retype Data | — | T | right-click → Data → Choose Data Type |
| Repeat Last Data Type | — | Y | right-click → Data → Last Used: `<type>` |
| Rename Variable | variable in Decompiler | L | right-click → Rename Variable |
| Retype Variable | variable in Decompiler | Ctrl+L | right-click → Retype Variable |
| Cycle Integer Types (byte/word/dword/qword) | — | B | right-click → Data → Cycle |
| Cycle String Types (char/string/unicode) | — | ' | right-click → Data → Cycle |
| Cycle Float Types (float/double) | — | F | right-click → Data → Cycle |
| Create Array | — | [ | right-click → Data → Create Array |
| Create Pointer | — | P | right-click → Data → pointer |
| Create Structure | selection of data | Shift+[ | right-click → Data → Create Structure |
| Set Comment (contextual: EOL/Pre/Post/Plate/Repeatable) | cursor in comment/code field | ; | right-click → Comments → Set... *(source-verified)* |
| Delete Comment | cursor on comment | Del | right-click → Comments → Delete *(source-verified)* |
| Show References To (live search) | — | Ctrl+Shift+F | right-click → References → Show References to... *(source-verified; not in printed cheat sheet — verify on your install)* |
| Go To | — | G | Navigation → Go To |
| Back | — | Alt+Left | — |
| Forward | — | Alt+Right | — |
| Next Function | — | Ctrl+Alt+F (also Ctrl+Down) | Navigation → Go To Next Function |
| Previous Function | — | Ctrl+Up | Navigation → Go To Previous Function |
| Next Bookmark | — | Ctrl+Alt+B | Navigation → Next Bookmark |
| Next Label | — | Ctrl+Alt+L | Navigation → Next Label |
| Bookmarks window | — | Ctrl+B | Window → Bookmarks |
| Decompiler window | — | Ctrl+E | Window → Decompile: `<function name>` |
| Toggle Listing / Function Graph | in Function Graph | Ctrl+Space | — *(rebindable)* |
| Function Graph window | — | — | Window → Function Graph |
| Data Type Manager window | — | — | Window → Data Type Manager |
| Symbol Tree window | — | — | Window → Symbol Tree |
| Symbol Table window | — | — | Window → Symbol Table |
| Search Memory | — | S | Search → Memory |
| Search Program Text | — | Ctrl+Shift+E | Search → Program Text |
| Search For... (instructions/tables/refs/patterns/scalars/strings) | — | — | Search → For `<what>` |
| Assemble / Patch Instruction | — | Ctrl+Shift+G | right-click → Patch Instruction |
| Rerun Script | — | Ctrl+Shift+R | — |
