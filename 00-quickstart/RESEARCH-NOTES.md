# Research notes — 00-quickstart (Phase 1)

All facts below were checked against the Ghidra GitHub repository at tag
`Ghidra_12.1.2_build` (release "Ghidra 12.1.2", published 2026-06-05 — current
stable release as of this research, per
https://github.com/NationalSecurityAgency/ghidra/releases). Where a file path
is cited without a full URL, it refers to
`https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_12.1.2_build/<path>`.
Java source citations point to the exact `setKeyBindingData`/`KeyStroke`
lines that define default shortcuts in this shipped version — these are the
literal defaults compiled into the app, not a guess.

---

## 1. Installation / setup

- **Current stable release: Ghidra 12.1.2** (tag `Ghidra_12.1.2_build`,
  published 2026-06-05). Download asset: `ghidra_12.1.2_PUBLIC_20260605.zip`,
  SHA-256 `b62e81a0390618466c019c60d8c2f796ced2509c4c1aea4a37644a77272cf99d`.
  Source: https://github.com/NationalSecurityAgency/ghidra/releases/tag/Ghidra_12.1.2_build
  (verified via `gh api repos/NationalSecurityAgency/ghidra/releases/latest`).

- **Download source**: GitHub releases page only — a prebuilt zip, no
  installer. Source: releases page above.

- **Required JDK: Java 21, 64-bit, JDK (not just JRE)**. Free LTS builds
  recommended: Adoptium Temurin or Amazon Corretto. Documented in
  `GhidraDocs/GettingStarted.md#software` @ tag `Ghidra_12.1.2_build`
  ("Java 21 64-bit Runtime and Development Kit (JDK)"). Also requires
  **Python 3.9–3.14** if you want Debugger or PyGhidra support (not needed for
  this quickstart module). Same source.

- **Platforms supported**: Windows 10 (build 1809 or later), Linux, macOS
  10.13 or later. Source: `GhidraDocs/GettingStarted.md#platforms-supported`.

- **Install steps (all OSes): unzip in place, no installer**. "Ghidra does
  not use a traditional installer program. Instead, the Ghidra distribution
  file is simply extracted in-place on the filesystem." Removing Ghidra =
  deleting the directory; no desktop shortcut or start-menu entry is created
  automatically. Source: `GhidraDocs/GettingStarted.md#installation-notes`.

- **First launch (GUI mode)**: from `<GhidraInstallDir>`, run `ghidraRun.bat`
  (Windows) or `ghidraRun` (Linux/macOS). Source:
  `GhidraDocs/GettingStarted.md#gui-mode`.

- **Java discovery**: the launch script looks for a supported JDK on `PATH`,
  or at `JAVA_HOME` if set (`JAVA_HOME` takes precedence over `PATH`). If the
  Java found doesn't meet the minimum version but is 1.8+, Ghidra uses it to
  help locate a supported version; if none can be found, the user is
  prompted to enter a Java home directory manually. Source:
  `GhidraDocs/GettingStarted.md#java-notes`. Troubleshooting entries for
  "Failed to find a supported JDK" and "'java' command could not be found in
  your PATH or with JAVA_HOME" are documented in the same file under
  Troubleshooting.

- **macOS Gatekeeper quirk**: on first launch, Gatekeeper may quarantine the
  prebuilt unsigned native components. Two documented workarounds: (1) run
  `xattr -d com.apple.quarantine ghidra_<version>_<date>.zip` **before**
  extracting, or (2) rebuild native components locally per the "Building
  Native Components" section before first launch. Source:
  `GhidraDocs/GettingStarted.md` (Known Issues → macOS / Installing Ghidra
  section, exact quote in transcript).

- **Headless mode**: `analyzeHeadless` (in `<GhidraInstallDir>/support/`) is
  the command-line, non-GUI analyzer for batch import/analysis/scripting; it
  is documented in `<GhidraInstallDir>/support/analyzeHeadlessREADME.html`
  (source markdown: `Ghidra/RuntimeScripts/Common/support/analyzeHeadlessREADME.md`).
  It can create/populate projects, import or process files, run pre-/post-
  scripts, and toggle analysis on/off — useful for batch work, out of scope
  for this quickstart module beyond a pointer.

- **In-app help**: pressing **F1** with the mouse over any window/menu/
  component opens context-sensitive help for that item; full indexed help is
  under `Help → Topics...`. Source: `GhidraDocs/GettingStarted.md` (Using
  Ghidra section).

---

## 2. First project + import + auto-analysis

- **New (non-shared) project**: `File → New Project...` from the Ghidra
  Project Window opens the **New Project** wizard. Step 3 of the wizard: leave
  **Non-Shared Project** selected (vs. Shared, which needs a Ghidra Server) to
  create a project not shared with others. Source:
  `Ghidra/Features/Base/src/main/help/help/topics/FrontEndPlugin/Creating_a_Project.htm`.
  Confirmed independently by the official beginner class notes: "Select
  File->New Project from the Ghidra Project Window. Select Project type:
  Non-Shared for people working alone / Shared for people working in a
  group." Source: `GhidraDocs/GhidraClass/Beginner/Introduction_to_Ghidra_Student_Guide.html`.

- **Import a binary**: `File → Import File...` (from either the Front-end
  Project Window or an open CodeBrowser tool) opens a file chooser, then the
  **Importer Dialog** (or **Batch Importer Dialog** if the file is a
  multi-program archive). Pressing OK performs the import; a results summary
  appears, and if initiated from an open CodeBrowser, the new program opens
  there. Drag-and-drop onto the Project Window tree is an alternative.
  Source: `Ghidra/Features/Base/src/main/help/help/topics/ImporterPlugin/importer.htm`.
  Default keyboard shortcut for this menu item: **I** (see shortcut table,
  section 6 — from the official Ghidra Cheat Sheet).

- **Auto-Analysis prompt on open**: "When a program first opens in [a] tool,
  it automatically kicks off Auto-Analysis and asks the user if they want to
  analyze the program." (I could not find the *exact* dialog button/title
  text such as "Yes"/"No" wording in the HTML help sources — see Unresolved
  list.) Source: `GhidraDocs/GhidraClass/Beginner/Introduction_to_Ghidra_Student_Guide.html`.
  The dialog shown is the **Auto Analysis Options** dialog (title confirmed
  in the dedicated help topic below); it lists all analyzers with checkboxes
  and can be skipped in future by unchecking "Show Analysis Options" under
  Auto Analysis tool options.
  Source: `Ghidra/Features/Base/src/main/help/help/topics/AutoAnalysisPlugin/AutoAnalysis.htm`
  ("A program imported through Front End will have no initial analysis
  applied to it. To force analysis, use the Analysis → Auto Analysis menu
  item. The Auto Analysis Options dialog is displayed...").

- **What "Analyze" does, high level** (same help topic): Auto Analysis is an
  event-driven pipeline of "Analyzer" plugins that react to program changes
  (e.g., new disassembly, new function). A typical chain: disassembly at
  entry points → Function/Subroutine Reference Analyzer creates functions at
  call destinations → Stack Analyzer builds a stack frame for each new
  function from stack references → Operand Analyzer looks at scalar operands
  for possible address references → Data Reference Analyzer resolves those
  references into strings/pointers/code (triggering further disassembly).
  Analyzers run at different priorities, and a single program change can
  cascade through several analyzers. Source: `AutoAnalysis.htm` (intro
  section). Independently corroborated, official beginner guide: "At a
  minimum [Auto-Analysis]: Starts at Entry Points, Disassembles by following
  flows, Creates functions at called locations, Creates Cross References."
  Source: `Introduction_to_Ghidra_Student_Guide.html`.

- **Analyzer options worth flagging to a first-timer**:
  - **ASCII Strings** — searches for valid ASCII strings using the same
    candidate-detection method as "Search for Strings", then filters
    candidates through a model trained to recognize genuine strings; creates
    String data at those addresses. Runs at very low priority. Source:
    `AutoAnalysis.htm` ("ASCII Strings Analyzer").
  - **Decompiler Parameter ID** — for each created function, runs the
    decompiler and imports back what it recovered: parameters, stack/register
    locals, return value, calling convention (stdcall/cdecl/thiscall/
    fastcall/...), and switch tables found via data-flow analysis. Source:
    `AutoAnalysis.htm` ("Decompiler Parameter ID Analyzer").
  - **Stack** (Stack Analyzer) — creates a stack frame (parameters + locals)
    for each newly defined function, based on references to the stack.
    Enabled via the "Stack References" option under the Function analyzer
    group. Source: `AutoAnalysis.htm` ("Stack Analyzer").

---

## 3. UI tour

All "open via" paths below are confirmed both in the dedicated help topic and
cross-checked against the official Ghidra Cheat Sheet
(`GhidraDocs/CheatSheet.html` @ tag `Ghidra_12.1.2_build`) "Windows" section.

- **Listing** — the main disassembly view: address / bytes / mnemonic /
  operand / comment / label fields per code unit, the traditional
  disassembly-listing look. It's the default central view in the CodeBrowser
  tool (no separate "open" step needed — it's always present). Source:
  `Ghidra/Features/Base/src/main/help/help/topics/CodeBrowserPlugin/CodeBrowser.htm`.

- **Decompiler** — shows a synthesized, interactive C-like rendering of the
  function at the cursor, kept in sync with the Listing (clicking a C
  expression can navigate/highlight the corresponding assembly and vice
  versa). Open via the toolbar icon or `Window → Decompile: <function name>`;
  default shortcut **Ctrl+E** (per Cheat Sheet). Source:
  `Ghidra/Features/Decompiler/src/main/help/help/topics/DecompilePlugin/DecompilerIntro.html`.

- **Symbol Tree** — hierarchical view of a program's symbols, organized into
  Externals / Function / Labels / Classes / Namespaces categories (rooted at
  the Global namespace). Open via toolbar icon or `Window → Symbol Tree`.
  Source: `Ghidra/Features/Base/src/main/help/help/topics/SymbolTreePlugin/SymbolTree.htm`.

- **Data Type Manager** — lets you browse, organize (via categories, like
  folders), and apply data types to a program; supports Built-in types (byte,
  word, string, …, not editable), user-defined types (Structures, Unions,
  Enums, Typedefs), and derived types (Pointers, Arrays); also manages data
  type archives shared across programs/projects/users. Open via
  `Window → Data Type Manager`. Source:
  `Ghidra/Features/Base/src/main/help/help/topics/DataTypeManagerPlugin/data_type_manager_description.htm`.

- **Function Graph** — a graph view of the function containing the cursor:
  each vertex is a code block (basic block) with a header and a mini-listing;
  edges represent control flow. Has a Primary View and a Satellite (overview)
  View. Open via `Window → Function Graph`; **Ctrl+Space** toggles between
  Listing and Function Graph view for the current function (this specific
  toggle-key binding is user-changeable in tool options, per the help text).
  Source: `Ghidra/Features/FunctionGraph/src/main/help/help/topics/FunctionGraphPlugin/Function_Graph.html`.

---

## 4. Basic annotations

All shortcuts below are the literal `KeyStroke`/`KeyBindingData` values
compiled into the Ghidra 12.1.2 source at the cited files — i.e., what the
shipped binary actually binds by default, not menu-path guesses. Cross-checked
against the official Cheat Sheet (`GhidraDocs/CheatSheet.html`) where that
document covers the same action.

- **Rename a label** (Listing): default shortcut **L**, opens the Edit Label
  Dialog (same dialog is used to add a label if there isn't one yet at that
  address — action name flips between "Add Label" / "Edit Label" depending on
  context, both bound to `L`). Source:
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/label/EditLabelAction.java`
  line 41: `KeyStroke.getKeyStroke(KeyEvent.VK_L, 0)`, and
  `.../label/AddLabelAction.java` line 34 (same binding). Confirmed in Cheat
  Sheet: "Edit Label — Label field — L", "Add Label — Address field — L".

- **Rename a function**: default shortcut **L** in the Decompiler window (on
  the function name token) — action "Rename Function". Source:
  `Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/RenameFunctionAction.java`
  line 39: `setKeyBindingData(new KeyBindingData(KeyEvent.VK_L, 0))`.
  Confirmed in Cheat Sheet: "Rename Function — Function name field — L".
  (In the plain Listing, the function's entry-point label can also be renamed
  via the same `L` / Edit Label path, since a function name is backed by a
  label.)

- **Rename a variable**: in the Decompiler, default shortcut **L** on a
  local-variable, global-variable, or structure-field token (separate action
  classes `RenameLocalAction`, `RenameGlobalAction`, `RenameFieldAction`, all
  bound to `KeyEvent.VK_L, 0`). Source:
  `.../decompile/actions/RenameLocalAction.java` line 53, `RenameGlobalAction.java`
  line 46, `RenameFieldAction.java` line 45. Confirmed in Cheat Sheet:
  "Rename Variable — Variable in decompiler — L".

- **Retype a variable or data item**:
  - In the **Decompiler**, retyping a local/global variable, struct field, or
    function return type uses **Ctrl+L** (`RetypeLocalAction`,
    `RetypeGlobalAction`, `RetypeFieldAction`, `RetypeReturnAction`, all bound
    to `KeyEvent.VK_L` + `DockingUtils.CONTROL_KEY_MODIFIER_MASK`). Source:
    `.../decompile/actions/RetypeLocalAction.java` lines 60–61 (representative
    of all four). Confirmed in Cheat Sheet: "Retype Variable — Variable in
    decompiler — Ctrl+L".
  - In the **Listing**, retyping/defining a data item's type uses **T**
    ("Choose Data Type" dialog, action `ChooseDataTypeAction`). Source:
    `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/data/ChooseDataTypeAction.java`
    line 38: `KeyStroke.getKeyStroke(KeyEvent.VK_T, 0)`. Confirmed in Cheat
    Sheet: "Define Data — T — right-click → Data → Choose Data Type".
  - Bonus (data-type cycling, not strictly "retype" but closely related and
    worth a cheatsheet line): **B** cycles byte→word→dword→qword,
    **F** cycles float→double, **'** (apostrophe) cycles char→string→unicode.
    Source: `Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/data/CycleGroup.java`
    lines 229, 241, 252; confirmed in Cheat Sheet ("Cycle Integer/String/Float
    Types").

- **Comments** (EOL / Pre / Post / Plate / Repeatable): Ghidra uses **one**
  contextual shortcut, **`;`** (semicolon), bound to the generic
  `EditCommentsAction` ("Set..."), which opens the **Set Comment(s)** dialog
  defaulting to whichever comment-type tab matches the field under the
  cursor. Source:
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/comments/CommentsActionFactory.java`
  line 134: `setKeyBindingData(new KeyBindingData(KeyEvent.VK_SEMICOLON, 0))`.
  There is no separate default keybinding per comment type — the same dialog
  has tabs for each type, and the right-click "Comments" submenu offers
  distinct menu items per type ("Set EOL Comment...", "Set Plate Comment...",
  etc.) with no keybinding of their own (verified: no `KeyBindingData` calls
  found for those individual per-type actions in
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/comments/CommentsPlugin.java`).
  Deleting a comment: **Delete** key when the cursor is on the comment.
  Source: same `CommentsPlugin.java` line 194 and `CommentsActionFactory.java`.
  Comment-type definitions (what each one is/where shown), per the help topic
  `Ghidra/Features/Base/src/main/help/help/topics/CommentsPlugin/Comments.htm`:
  - **EOL** — displayed to the right of the instruction/data.
  - **Pre** — displayed above the instruction.
  - **Post** — displayed below the instruction.
  - **Plate** — displayed as a block header above the instruction/function,
    automatically surrounded by `*`s (this is the "banner" comment style seen
    above functions).
  - **Repeatable** — displayed to the right of the instruction like an EOL
    comment (only if no EOL comment is set), *and* also shown at every
    "from" address of a reference to this code unit (if that from-address has
    no EOL/repeatable comment of its own) — i.e., it "repeats" at call sites.

---

## 5. Cross-references, bookmarks, search

- **"Show References To" / XREFs**:
  - The **Location References Dialog** ("Show References to <item>") performs
    a live search for references to whatever is under the cursor (a label,
    function, global, data type, structure field, etc.) — this is broader
    than just what's stored in the database; it actively looks for additional
    references. Default shortcut in this version: **Ctrl+Shift+F**. Source:
    `Ghidra/Features/Base/src/main/java/ghidra/app/actions/AbstractFindReferencesDataTypeAction.java`
    line 38: `KeyStroke.getKeyStroke(KeyEvent.VK_F, DockingUtils.CONTROL_KEY_MODIFIER_MASK | InputEvent.SHIFT_DOWN_MASK)`
    (used by `FindReferencesToAction` in
    `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/navigation/locationreferences/FindReferencesToAction.java`).
    Help topic:
    `Ghidra/Features/Base/src/main/help/help/topics/LocationReferencesPlugin/Location_References.html`.
    **Caveat**: the official Cheat Sheet (`GhidraDocs/CheatSheet.html`) lists
    "Cross References" only as right-click → References → "Show References
    to <context>" with **no keyboard shortcut column filled in** — it doesn't
    show Ctrl+Shift+F. The source-code binding above is authoritative for
    what ships, but flagging the discrepancy since the printed cheat sheet
    disagrees (possibly not refreshed for every point release — see
    Unresolved list).
  - Separately, the inline **"XREF[n]:"** / **"[more]"** text shown directly
    in the Listing at a referenced location is *not* a live search — it's
    simply a display of references already recorded in the program database.
    Double-clicking it opens a dialog listing all recorded Xrefs for that
    location. Source:
    `Ghidra/Features/Base/src/main/help/help/topics/CodeBrowserPlugin/CodeBrowser.htm`.

- **Bookmarks**:
  - **Types**: Note (user-added, purple), Info (added by a plugin, cyan),
    Analysis (added during Auto Analysis, orange), Error (added by
    disassembler/Auto Analysis on an unexpected condition, red), Unknown
    (custom type from a not-currently-configured plugin, magenta). Ghidra
    marks these in the Code Browser's Marker Margin (with tooltips) and
    Navigation Margin. Source:
    `Ghidra/Features/Base/src/main/help/help/topics/BookmarkPlugin/Bookmarks.htm`.
  - **Creating one**: position the cursor at an address, right-click in the
    Code Browser → **Bookmark**, which opens the "Note Bookmark" dialog
    (address pre-filled, optional Category/Description). No default keyboard
    shortcut for *creating* a bookmark was found bound in source (see
    Unresolved). Source: same `Bookmarks.htm`.
  - **Bookmark Manager / Bookmarks window**: lists every bookmark in the
    program (type, category, description, address, label, code unit);
    clicking a row navigates the Code Browser there. Open via the bookmark
    toolbar icon or `Window → Bookmarks`; default shortcut **Ctrl+B** per the
    official Cheat Sheet. There's also a dedicated **Next Bookmark**
    navigation shortcut, **Ctrl+Alt+B**, to step through bookmarks in the
    Listing. Sources: `Bookmarks.htm` (open-via) and
    `GhidraDocs/CheatSheet.html` (Ctrl+B, Ctrl+Alt+B) — the window-opening
    keybinding for the Bookmarks action itself wasn't found bound with
    `KeyBindingData` in `BookmarkPlugin.java`, so treat Ctrl+B as the Cheat
    Sheet's documented default rather than source-verified (see Unresolved).

- **Search**:
  - **Search → Program Text** (default shortcut **Ctrl+Shift+E** per Cheat
    Sheet) offers two modes: a **Program Database Search** (fast, searches
    the underlying database) and a **Listing Display Search** (slower —
    renders each address's displayed string to match against, exactly what
    you'd see scrolling the Listing). Source:
    `Ghidra/Features/Base/src/main/help/help/topics/Search/Search_Program_Text.htm`.
  - **Search → Memory** (default shortcut **S** per Cheat Sheet) searches raw
    bytes in memory using a selectable Search Format (e.g., Hex — field
    validates input against the active format) for a value/byte pattern.
    Source: `Ghidra/Features/Base/src/main/help/help/topics/Search/Search_Memory.htm`.
  - **Search → For ...** submenu covers specialized searches: Matching
    Instructions, Address Tables, Direct References, Instruction Patterns,
    Scalars, Strings — each opens a dedicated results/query dialog. Source:
    Cheat Sheet ("Search For ... → Search → For <what>") plus the individual
    help topics under `Ghidra/Features/Base/src/main/help/help/topics/Search/`.

---

## 6. Shortcut cheat table

Primary source for this table: **`GhidraDocs/CheatSheet.html`** @ tag
`Ghidra_12.1.2_build` — this is Ghidra's own official printable cheat sheet,
shipped in the repo (not a third-party summary). Cross-checked line-by-line
against source `KeyBindingData`/`KeyStroke` definitions where noted above;
discrepancies are called out explicitly.

| Action | Context | Shortcut | Menu / path |
|---|---|---|---|
| New Project | — | Ctrl+N | File → New Project |
| Open Project | — | Ctrl+O | File → Open Project |
| Close Project | — | Ctrl+W | File → Close Project |
| Save Project | — | Ctrl+S | File → Save Project |
| Import File | — | I | File → Import File |
| Export Program | — | O | File → Export Program |
| Open File System | — | Ctrl+I | File → Open File System |
| Ghidra Help (context) | hover on action | F1 | Help → Contents |
| Set Key Binding | hover on action | F4 | — |
| Key Bindings (editor) | — | — | Edit → Tool Options → Key Bindings |
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
| Set/Edit Comment (contextual: EOL/Pre/Post/Plate/Repeatable) | cursor in comment/code field | ; | right-click → Comments → Set... *(source-verified, not in printed Cheat Sheet)* |
| Delete Comment | cursor on comment | Del | right-click → Comments → Delete *(source-verified)* |
| Show References To (live search) | — | Ctrl+Shift+F | right-click → References → Show References to... *(source-verified; not shown with a key in the printed Cheat Sheet — see section 5 caveat)* |
| Go To | — | G | Navigation → Go To |
| Back | — | Alt+Left | — |
| Forward | — | Alt+Right | — |
| Next Function | — | Ctrl+Alt+F (also Ctrl+Down) | Navigation → Go To Next Function |
| Previous Function | — | Ctrl+Up | Navigation → Go To Previous Function |
| Next Bookmark | — | Ctrl+Alt+B | Navigation → Next Bookmark |
| Next Label | — | Ctrl+Alt+L | Navigation → Next Label |
| Bookmarks window | — | Ctrl+B | Window → Bookmarks |
| Decompiler window | — | Ctrl+E | Window → Decompile: `<function name>` |
| Toggle Listing / Function Graph | in Function Graph plugin | Ctrl+Space | — *(rebindable in tool options)* |
| Function Graph window | — | — | Window → Function Graph |
| Data Type Manager window | — | — | Window → Data Type Manager |
| Symbol Tree window | — | — | Window → Symbol Tree |
| Symbol Table window | — | — | Window → Symbol Table |
| Search Memory | — | S | Search → Memory |
| Search Program Text | — | Ctrl+Shift+E | Search → Program Text |
| Search For... (instructions/address tables/refs/patterns/scalars/strings) | — | — | Search → For `<what>` |
| Assemble / Patch Instruction | — | Ctrl+Shift+G | right-click → Patch Instruction |
| Rerun Script | — | Ctrl+Shift+R | — |

Sources for each row are as cited inline in sections 2–5 above (source code
for anything marked "source-verified"; `GhidraDocs/CheatSheet.html` for
everything else).

---

## Unresolved / needs manual verification against an installed Ghidra

- **Exact wording/buttons of the "analyze now?" first-open dialog** (e.g.,
  literal title and Yes/No button text). Only paraphrased behavior was found
  in the official Beginner class notes ("...asks the user if they want to
  analyze the program") — the precise dialog copy wasn't found in any HTML
  help file. Verify by importing a binary in an installed 12.1.2 and noting
  the exact dialog text.
- **Default keybinding for *creating* a Note Bookmark** (as opposed to
  deleting one, or opening the Bookmarks window). No `KeyBindingData` call
  for a bookmark-creation action was found in
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/bookmark/BookmarkPlugin.java`
  at this tag — help text only documents the right-click → Bookmark path.
  Ctrl+B (open Bookmarks window) is Cheat-Sheet-sourced only, not confirmed
  against a `KeyBindingData` call in `BookmarkPlugin.java` — worth a quick
  double-check in Edit → Tool Options → Key Bindings on an installed copy.
- **Discrepancy**: source code binds "Show References To" (Location
  References dialog) to Ctrl+Shift+F (`AbstractFindReferencesDataTypeAction.java`),
  but the shipped `GhidraDocs/CheatSheet.html` at the same tag does not list
  a keyboard shortcut for this action, only the right-click path. Possible
  the cheat sheet simply wasn't updated for this action, or the binding is
  contextual/conditional in a way the static source read doesn't capture.
  Verify by checking Edit → Tool Options → Key Bindings for "Find References
  To" on an installed 12.1.2.
- **Live first-run UI details in general** (macOS Gatekeeper dialog wording,
  first-run project-window layout, any OS-specific first-launch prompts
  beyond Gatekeeper) could only be described from written docs, not observed
  directly — no local Ghidra install was available for this research pass.
- **Whether individual per-comment-type menu actions (Set EOL Comment...,
  Set Plate Comment..., etc.) have ever had their own keybindings in some
  other release** — only confirmed no such binding exists in this exact
  tag's `CommentsPlugin.java`/`CommentsActionFactory.java`; did not diff
  across all historical releases.
