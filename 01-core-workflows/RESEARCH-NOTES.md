# Research notes — 01-core-workflows (Phase 3)

All facts below were checked against the Ghidra GitHub repository at tag
`Ghidra_12.1.2_build` (release "Ghidra 12.1.2", published 2026-06-05 — same
release pinned for 00-quickstart; see `00-quickstart/RESEARCH-NOTES.md` §1
for the release/JDK/platform details, not repeated here). Where a file path
is cited without a full URL, it refers to
`https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_12.1.2_build/<path>`.
Same sourcing convention as 00-quickstart: Java source citations point to
the literal `KeyBindingData`/`KeyStroke`/`MenuData` calls compiled into this
shipped version; help-topic citations point to the HTML/HTM files under
`.../src/main/help/help/topics/` that ship inside the corresponding feature
module; where source and the official Cheat Sheet
(`GhidraDocs/CheatSheet.html`) both cover an action, both are cited.

---

## 1. Data types & structures

- **Three data type categories**: Built-in (Java-implemented, e.g. byte,
  word, string — not editable/renameable/movable), user-defined (Structure,
  Union, Enum, Typedef — the only four that are user-creatable/editable),
  derived (Pointer, Array — created/deleted, named from base type). Source:
  `Ghidra/Features/Base/src/main/help/help/topics/DataTypeManagerPlugin/data_type_manager_description.htm`
  ("Basic Concepts" section).
- **Creating New User Defined Data Types**: right-click a category in the
  Data Type Manager tree → `New → Structure` / `New → Union` / `New → Enum`
  / `New → Function Definition`; each opens the matching editor. No
  `KeyBindingData` found for any of these actions and the Cheat Sheet
  likewise lists no shortcut column for "New Structure" (only the ❖
  right-click path) — consistent with "menu-only" action. Source: same
  `data_type_manager_description.htm` ("Creating New User Defined Data
  Types"); `GhidraDocs/CheatSheet.html` row "New Structure — data type
  container — ❖ → New → Structure".
- **Typedef creation, two paths**: right-click an existing type → `New
  Typedef on <Name>` (typedef created in the same category as the base
  type), or `New Typedef...` from any folder (dialog: pick name + base
  type). A Pointer-based typedef supports extra Pointer-Typedef Settings
  (auto-typedef rendering examples given verbatim: `char *
  __((space(ram)))`, `int * __((offset(0x8)))`, `pointer
  __((image-base-relative))`). Source: same file, "Creating a Typedef" /
  "Pointer-Typedef Settings" sections.
- **Pointer creation**: `New Pointer to <Name>`; created in the base type's
  category, or the active program's root category if the base type came
  from the Built-in archive. Source: same file, "Creating a Pointer".
- **Create Structure from a Listing selection**: default shortcut
  **Shift+[**, confirmed in 00-quickstart's own cheat-sheet research (this
  module cross-references rather than re-verifying) — `Ghidra/Features/Base/.../CycleGroup.java`
  context aside, the binding itself was already source/cheat-sheet
  confirmed in `00-quickstart/RESEARCH-NOTES.md` §6 cheat table row "Create
  Structure".
- **Global "Edit Data Type" shortcut**: **Ctrl+Shift+D**, opens a Data Type
  Chooser Dialog. Source: `data_type_manager_description.htm`, "Editing a
  Data Type" section (stated directly in prose, not a `KeyBindingData`
  citation — this help doc states the binding as fact, no source-code cross
  check performed for this specific one; see Unresolved).
- **Create Enum from Selection**: select ≥2 enums → merges names/values into
  one new enum; duplicate values keep only the first active entry but all
  names survive as a documenting comment; duplicate names get
  underscore-suffixed. Source: same file, "Creating a new Enum from a
  Selection of Enums".
- **Structure/Union Editor**: component table (offset/length/mnemonic/
  datatype/name/comment); Apply Changes propagates to every data item using
  the type in the program; Undo/Redo Change is an editor-local stack,
  cleared once changes are applied back; bit-level view for bitfields,
  byte-order-reversed for little-endian to keep bitfields contiguous.
  Source:
  `Ghidra/Features/Base/src/main/help/help/topics/DataTypeEditors/StructureEditor.htm`.
- **Enum Editor**: **F2** or double-click a cell to edit; Tab/Shift-Tab/
  Up/Down navigate cells while editing; Size field is a dropdown and
  controls applied byte-width (explicitly called out: wrong size →
  unexpected Decompiler results); hex/decimal toggle for the value column.
  Source:
  `Ghidra/Features/Base/src/main/help/help/topics/DataTypeEditors/EnumEditor.htm`.
- **Data Type Archives — two user-creatable kinds**: File Archive (`.gdt`
  file, anywhere on disk, opened read-only by default, one editor at a
  time) and Project Archive (inside the Ghidra project tree, versioned/
  shareable, normally opened for editing). Plus the always-present Built-in
  archive. Dragging a `.gdt` onto the Project Window creates a populated
  Project Archive. Source: same `data_type_manager_description.htm`,
  "Working with Data Type Archives" + "File Data Type Archive" / "Project
  Data Type Archive" subsections.
- **Source Archive tracking / sync actions**: `Update Datatypes From`,
  `Commit Datatypes To`, `Revert Datatypes From`, `Disassociate Datatypes
  From <archive>` — each opens a dialog with rows flagged `UPDATE` /
  `COMMIT` / `CONFLICT` / `ORPHAN` as applicable. Source:
  `Ghidra/Features/Base/src/main/help/help/topics/DataTypeManagerPlugin/data_type_manager_archives.html`.
- **Archive Architecture assignment**: optional per-archive Data
  Organization (primitive sizing, alignment, struct packing), recommended
  when an archive targets a specific processor/compiler. Source:
  `data_type_manager_description.htm`, "Setting Data Type Archive
  Architecture".
- **C-Parser (`File → Parse C Source...`)**: extracts structs/enums/
  typedefs/function signatures from C headers into a program or archive;
  two-phase (CPP macro expansion, dumped to `CParserPlugin.out` in the
  user's home directory for debugging, then C-syntax parse); integer-valued
  `#define`s become Equates. Menu path confirmed via source (not just help
  text). Sources:
  `Ghidra/Features/Base/src/main/help/help/topics/CParserPlugin/CParser.htm`
  and
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/cparser/CParserPlugin.java`
  line ~129: `String[] menuPath = { ToolConstants.MENU_FILE, "Parse C
  Source..." };`.

## 2. Decompiler tuning: calling conventions & function signatures

- **Edit Function dialog**: right-click a function signature → `Edit
  Function...`, default shortcut **F**. Source:
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/function/EditFunctionAction.java`
  — `setKeyBindingData(new KeyBindingData(KeyEvent.VK_F, 0));`, popup menu
  text `"Edit Function..."`.
- **Function Editor Dialog fields** (Function Signature text field with a
  limited parser; Function Name; Calling Convention combobox — "will have
  no affect on storage if the Custom Storage checkbox has been selected";
  Function Attributes — Varargs, In Line, No Return, Use Custom Storage;
  Parameters/Return Type table with Add/Remove/Up/Down, `(auto)`/`(ptr)`
  storage tags; Call Fixup combobox sourced from the program's `.cspec`;
  "Commit all return/parameter details" checkbox — auto-enables on changes
  requiring a full commit, and a full commit with custom storage/datatype
  changes imposes `USER_DEFINED` Signature Source). Source:
  `Ghidra/Features/Base/src/main/help/help/topics/FunctionPlugin/Variables.htm`
  ("Edit Function" through "Commit all return/parameter details" sections).
- **Calling convention list is per-`.cspec`, not global**: verified by
  reading two actual compiler spec files. `x86win.cspec` defines
  `__stdcall`, `__cdecl`, `__fastcall`, `__thiscall` prototypes.
  `x86-64-win.cspec` defines `__fastcall` (used inside `<default_proto>`,
  i.e. it *is* the default convention for that spec) and `__thiscall`.
  Sources: `Ghidra/Processors/x86/data/languages/x86win.cspec` (grep for
  `<prototype name="...">`), `Ghidra/Processors/x86/data/languages/x86-64-win.cspec`
  (`<default_proto><prototype name="__fastcall" extrapop="8"
  stackshift="8">`).
- **Signature Source priority**: `DEFAULT` (1, lowest) < `ANALYSIS` (2) =
  `AI` (2) < `IMPORTED` (3) < `USER_DEFINED` (4, highest) — the `AI` source
  type is present in this 12.1.2 tag alongside the more familiar four.
  Source:
  `Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/symbol/SourceType.java`
  (constructor calls `DEFAULT("Default", 1, 2)`, `ANALYSIS("Analysis", 2,
  0)`, `AI("AI", 2, 4)`, `IMPORTED("Imported", 3, 3)`, `USER_DEFINED("User
  Defined", 4, 1)` — second constructor arg is priority).
- **Override Signature / Edit Signature Override** (Decompiler, right-click
  a call): `OverridePrototypeAction` ("Override Signature", popup menu
  under "Decompile") lets you set a call-site-local prototype without
  editing the called function; explicitly shows a warning dialog for direct
  calls recommending fixing the function itself instead.
  `EditPrototypeOverrideAction` ("Edit Signature Override") edits an
  existing override. Neither has a `KeyBindingData` call in source — no
  default shortcut for either. Sources:
  `Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/OverridePrototypeAction.java`,
  `.../EditPrototypeOverrideAction.java`.
- **Commit Params/Return**: Decompiler right-click, default shortcut **P**.
  "Commit Local Names" (a separate action, no default shortcut) commits
  local variable names only. Source:
  `Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/CommitParamsAction.java`
  — `setKeyBindingData(new KeyBindingData(KeyEvent.VK_P, 0));`;
  `.../CommitLocalsAction.java` (popup text "Commit Local Names", no
  `KeyBindingData` call found).

## 3. Control-flow & reference analysis

- **RefType / FlowType full enumeration**: flow types
  `INVALID, FLOW, FALL_THROUGH, UNCONDITIONAL_JUMP, CONDITIONAL_JUMP,
  UNCONDITIONAL_CALL, CONDITIONAL_CALL, TERMINATOR, COMPUTED_JUMP,
  CONDITIONAL_TERMINATOR, COMPUTED_CALL, CALL_TERMINATOR,
  COMPUTED_CALL_TERMINATOR, CONDITIONAL_CALL_TERMINATOR,
  CONDITIONAL_COMPUTED_CALL, CONDITIONAL_COMPUTED_JUMP, JUMP_TERMINATOR,
  INDIRECTION, CALL_OVERRIDE_UNCONDITIONAL, JUMP_OVERRIDE_UNCONDITIONAL,
  CALLOTHER_OVERRIDE_CALL, CALLOTHER_OVERRIDE_JUMP`; data types `THUNK,
  DATA, PARAM, DATA_IND, READ, WRITE, READ_WRITE, READ_IND, WRITE_IND,
  READ_WRITE_IND, EXTERNAL_REF`. Source:
  `Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/symbol/RefType.java`
  (all `public static final FlowType`/`RefType` field declarations, lines
  ~97–445).
- **Default symbol name prefixes by reference type**: `LAB_<addr>` (branch
  flow), `SUB_<addr>` (call flow), `DAT_<addr>` or a type-named prefix like
  `DWORD_<addr>` (data reference; prefix replaced by the datatype name if
  the address holds defined data), `OFF_<addr>` (offcut reference). Source:
  `Ghidra/Features/Base/src/main/help/help/topics/ReferencesPlugin/References_from.htm`,
  "Reference Destination Symbols" table.
- **Manual reference actions**: `References → Add Reference from...` (Add
  Reference Dialog, any permitted type); `References → Create Default
  Reference`, default shortcut **Alt+R** (menu wording varies: "Create
  Memory/Stack/Register Reference"; repeated invocation on a scalar operand
  in a multi-space program cycles candidate memory spaces);
  `References → Delete References`. The `{Alt-R}` binding notation is
  stated directly in the help doc's own text (a documented default, not
  independently source-cross-checked against a `KeyBindingData` call — see
  Unresolved). Source: same `References_from.htm`, "Actions for Creating
  and Deleting References From a Code Unit".
- **Flow Override** (`FlowOverride` enum): `NONE, BRANCH, CALL,
  CALL_RETURN, RETURN` — five values, with P-Code remapping documented in
  Javadoc for each (e.g. `BRANCH`: `CALL → BRANCH`, `CALLIND → BRANCHIND`,
  `RETURN → BRANCHIND`). UI action: right-click an instruction → `Modify
  Instruction Flow...`, no `KeyBindingData` call found in source (no
  default shortcut). Sources:
  `Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/listing/FlowOverride.java`
  (enum declarations + Javadoc P-Code mappings);
  `Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/disassembler/SetFlowOverrideAction.java`
  (popup text `"Modify Instruction Flow..."`, class-level scoping
  `class SetFlowOverrideAction extends ListingContextAction`, no
  `KeyBindingData` present).
- **Fallthrough override**: `Fallthrough → Set...` opens the Set
  Fallthrough Address dialog (Default vs. User radio buttons; adds a
  "Fallthrough Override" comment); `Fallthrough → Auto override` skips data
  to find the real next instruction; `Fallthrough → Clear Overrides`
  removes it. Source:
  `Ghidra/Features/Base/src/main/help/help/topics/FallThroughPlugin/Override_Fallthrough.htm`.
- **P-Code graphing from the Decompiler**: `Graph → Graph Control Flow`
  (`PCodeCfgAction`, class name "Graph PCode Control Flow", menu bar group
  "graph") and `Graph → Graph Data Flow` (`PCodeDfgAction`, "Graph PCode
  Data Flow", same group); both require a `GraphDisplayBroker` tool
  service; neither has a `MenuData`-adjacent `KeyBindingData` call. Source:
  `Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/PCodeCfgAction.java`,
  `.../PCodeDfgAction.java`.
- **Location References Dialog also covers data types**: right-click a
  data type → Find References To/Find Uses Of shows every place the type is
  applied (memory and function signatures) and highlights it in the Data
  Type Manager tree; only rows backed by an actual database reference are
  deletable. Source:
  `Ghidra/Features/Base/src/main/help/help/topics/LocationReferencesPlugin/Location_References.html`.

## 4. Function ID (FID)

- **Hashing model**: per function, a **full hash** (mnemonic + some
  addressing-mode info + specific register operands, excludes specific
  constant values) and a **specific hash** (full hash plus non-address
  constant operand values via heuristic). Parent/child function
  relationships are used to disambiguate matches with identical hashes.
  Source:
  `Ghidra/Features/FunctionID/src/main/help/help/topics/FunctionID/FunctionID.html`
  ("Hashing", "Parents and Children").
- **Single Match conditions**: candidates narrow to one function name; the
  function has no imported/user-defined name already (bypassable via
  "Always apply FID labels" option); match score exceeds the instruction
  count threshold. Below-threshold/ambiguous results become a **Multiple
  Match** (score clears the multiple match threshold) or nothing at all
  (score too low). Both threshold names — "Instruction count threshold" and
  "Multiple match threshold" — and the scoring rule (1.0 per matching
  instruction with no constant operands; calls/no-ops score 0) are
  documented directly. Source: same file, "Single Matches", "Multiple
  Matches", "Analysis Options", "Scoring and Disambiguation".
- **Ships with**: Microsoft Visual Studio statically-linked library
  databases for x86, split by bitness and VS version, each with debug and
  production variants; FID databases are processor-specific. Source: same
  file, "Overview".
- **Runs as**: an Auto Analysis analyzer (listed as "Function ID" in the
  Auto Analysis Options dialog) or on-demand via the **One Shot** menu.
  Source: same file, "Overview" ("Function ID generally runs as part of
  Auto Analysis but can also be initiated at any time by the user from the
  One Shot menu").
- **Function ID Plug-in enabling**: not enabled by default — `File →
  Configure → Ghidra Core → FidPlugin` checkbox. Actions live under
  `Tools → Function ID`: Choose active FidDbs..., Create new empty FidDb...
  (must be outside the Ghidra install dir — considered read-only),
  Attach existing FidDb... (preference persists across sessions), Detach
  attached FidDb... (shipped databases can only be deactivated, not
  detached), Populate FidDb from programs... (dialog fields: Fid Database,
  Library Family Name, Library Version, Library Variant, Base Library, Root
  Folder, Language [4-field Language ID], Common Symbol File). Source:
  `Ghidra/Features/FunctionID/src/main/help/help/topics/FunctionID/FunctionIDPlugin.html`.

## 5. Version Tracking basics

- **Core vocabulary** (Session, Association, Match, Implied Match, Markup
  Item, Correlator) — definitions and the accept/block relationship between
  matches (accepting one blocks conflicting associations; applying markup
  auto-accepts a match; accepting a function match auto-generates Implied
  Matches for called functions on both sides). Source:
  `Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/Version_Tracking_Intro.html`.
- **Starting a session**: blue-footprints icon in the Ghidra Project Window
  / Tool Chest launches the tool; drag one or two programs onto it, or use
  `Create Session` inside an open VT tool; wizard panels are New Session →
  Preconditions → Summary. Preconditions run "validator" checks (function
  count differential, memory-map similarity, etc.) before matching.
  Sources:
  `Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_Wizard.html`,
  `VT_Tool.html`. Independently cross-checked (same launch-icon description,
  same validator list) against the official class notes:
  `GhidraDocs/GhidraClass/Intermediate/VersionTracking.html` ("Click on the
  blue footprints icon in the Ghidra Program Manager...").
- **Correlator list** (Data Match: Exact/Duplicate/Similar Data Match;
  Function Match: Exact Function Bytes/Instructions Match, Duplicate
  Function Match, Exact Function Mnemonics Match, Legacy Import Correlator;
  Symbol Name Match: Exact/Duplicate Exact/Similar Symbol Name Match;
  Reference correlators: Data Reference, Function Reference, Combined
  Function and Data Reference Correlator; plus internal Implied and Manual
  Match correlators). Source:
  `Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_Correlators.html`
  (section headers).
- **Recommended workflow**: run exact correlators first (unique/certain
  matches, markup lines up exactly); select all with **Ctrl-A** in the
  match table, then Apply Markup to accept+apply in bulk; only then move to
  fuzzier correlators needing individual review. Source:
  `Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_Workflow.html`
  ("What Correlator Should I Use First?", "Exact Correlators").
- **Automatic Version Tracking**: fixed correlator sequence (Exact Symbol
  Name → Exact Data → Exact Function Bytes → Exact Function Instructions →
  Exact Function Mnemonics → Duplicate Function Instructions → one
  Reference correlator), options at `Edit → Tool Options → Version
  Tracking → Auto Version Tracking`, explicitly described as conservative
  (won't match everything, aims to avoid mistakes over completeness).
  Source:
  `Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_AutoVT.html`.

## 6. Scripting outlook

- **Script Manager**: `Window → Script Manager` — confirmed via
  `GhidraDocs/CheatSheet.html` row ("Script Manager | Window → Script
  Manager", no shortcut column filled — cheat-sheet-sourced only, not
  independently confirmed against a `KeyBindingData` call in source; the
  Script Manager's own action-registration source file
  (`GhidraScriptMgrPlugin.java`) was checked and contains no
  `KeyBindingData`/`MenuData` call for opening the window itself — see
  Unresolved). "Rerun Script" shortcut **Ctrl+Shift+R** — also
  Cheat-Sheet-sourced (matches the same row already source-independent in
  00-quickstart's cheat table, not re-derived from source here).
- **Script header metadata** (`@category`, `@keybinding`, `@menupath`,
  `@toolbar`) and their effect on Script Manager table columns / tool
  integration (In Tool checkbox, Scripts menu placement, toolbar button).
  Source:
  `Ghidra/Features/Base/src/main/help/help/topics/GhidraScriptMgrPlugin/GhidraScriptMgrPlugin.htm`.

## Diagram sourcing (README.md pipeline)

- **SLEIGH's role**: "SLEIGH is Ghidra's specification language for
  describing processor instructions. Specification files are read in for a
  Program, and once configured, Ghidra's SLEIGH engine can: Disassemble
  machine instructions from the underlying bytes and Produce the raw p-code
  consumed by the Decompiler and other analyzers." Source:
  `Ghidra/Features/Decompiler/src/main/help/help/topics/DecompilePlugin/DecompilerConcepts.html`,
  "SLEIGH Specification Files" section (quoted near-verbatim in the
  diagram's caption).
- **P-Code as Ghidra's IR, consumed by the Decompiler**: "P-code is
  Ghidra's Intermediate Representation (IR) language. When analyzing a
  function, the Decompiler translates every machine instruction into
  p-code first and performs its analysis directly on the operators and
  variables of the language." Source: same file, "P-code" (opening
  section). Cross-referenced against the existence of the P-Code Reference
  Manual itself at `GhidraDocs/languages/html/pcoderef.html` (confirmed
  present at this tag, last-updated date 2026-01-16 per its own header).

---

## Unresolved / needs manual verification against an installed Ghidra

- **Global "Edit Data Type" shortcut (Ctrl+Shift+D)** — taken directly from
  help-doc prose in `data_type_manager_description.htm`, not
  cross-verified against a `KeyBindingData` call in the corresponding
  action's Java source (the exact action class wasn't identified/fetched
  in this research pass). Worth a quick check in `Edit → Tool Options →
  Key Bindings` on an installed 12.1.2.
- **Create Default Reference `{Alt-R}`** — this binding notation comes
  directly from the help doc's own text (`References_from.htm`), not from
  reading a `KeyBindingData` call in the `ReferencesPlugin` action source
  (not fetched in this pass). Same caveat as above.
- **Script Manager window's own open-shortcut and the "Rerun Script"
  Ctrl+Shift+R binding** — both are Cheat-Sheet-sourced only in this
  research pass; `GhidraScriptMgrPlugin.java` was fetched and contains no
  `KeyBindingData`/`MenuData` call for opening the window (the action is
  presumably registered by a different class, e.g. a provider or a
  generic "show component" action, not investigated further). Low risk —
  the Cheat Sheet is Ghidra's own shipped reference — but not
  source-code-verified the way the F/P/Alt+R-style bindings in this module
  are.
- **`FunctionIDDebug.html`** (a third FID help topic, alongside
  `FunctionID.html` and `FunctionIDPlugin.html`) was fetched but not
  reviewed in this pass — it appears to cover low-level FID
  troubleshooting/internals not needed for this module's scope. Worth a
  look if a future module needs FID internals (e.g. hash algorithm
  debugging).
- **Live UI verification in general** — as with 00-quickstart, no local
  Ghidra install was available for this research pass; all dialog
  layouts, field names, and behaviors described here come from the shipped
  help HTML and Java source, not from operating an installed copy.
