# Progress Log

Plan reference: see [PLAN.md](PLAN.md) for the full phase table, module
contents, model recommendations, and the visual/interactive material list.
This file only tracks what's done, what's next, and facts later phases need.

## Completed

- Phase 0 — Repo setup: git initialized, public GitHub repo `ghidra-tutor`
  created, module folder skeleton created, root `README.md`, `PLAN.md`,
  `CLAUDE.md` and this `PROGRESS.md` added.
- Phase 1 — 00-quickstart: Guides. Added `00-quickstart/README.md` (module
  index + Mermaid Import→Analyze→Browse→Annotate→Export pipeline diagram)
  and six guides: installation/setup, first project+import+auto-analysis,
  UI tour (Listing/Decompiler/Symbol Tree/Data Type Manager/Function Graph),
  basic annotations (rename/retype/comment), xrefs/bookmarks/search, and a
  markdown shortcut cheatsheet. All facts verified against Ghidra 12.1.2
  docs/source by a research pass; sourcing kept in
  `00-quickstart/RESEARCH-NOTES.md`.
- Phase 2 — 00-quickstart: Exercises + interactive shortcut HTML. Added
  `exercises/<slug>/{problem.md, solution.md}` for all 5 Phase 1 topics
  (`01-installation-verify`, `02-first-import-analysis`,
  `03-ui-tour`, `04-basic-annotations`, `05-xrefs-bookmarks-search`), and
  `00-quickstart/interactive-cheatsheet.html` (self-contained, filterable/
  sortable shortcut table, no dependencies). Exercises 02–05 share one
  self-compiled, stripped sample binary (`exercises/02-first-import-analysis/
  sample/{sample.c, build.sh}`) instead of five separate throwaway ones, so
  the exercises chain into one continuous RE session (import → tour →
  annotate → xref the same program), matching the README's pipeline
  diagram. Added root `.gitignore` for build artifacts (`*.bin`, `*.o`) and
  local Ghidra project files (`*.gpr`, `*.rep/`).
- Phase 3 — 01-core-workflows: Guides + diagram. Added
  `01-core-workflows/README.md` (module index + Mermaid Raw bytes → Disassembly
  (SLEIGH) → P-Code → Decompiler-output diagram) and six guides: data types &
  structures (Data Type Manager, Structure/Enum editors, typedefs/pointers,
  File vs Project archives, C-Parser), decompiler tuning (calling
  conventions, Function Editor dialog, Signature Source priority incl. the
  new `AI` source type, call-site signature overrides, Commit Params/Return),
  control-flow/reference analysis (RefType/FlowType enumeration, default
  symbol-name prefixes, Flow/Fallthrough Override, P-Code CFG/DFG graphing),
  Function ID (FID hashing model, Single/Multiple Match rules, FID database
  creation), Version Tracking basics (session wizard, correlators,
  Automatic Version Tracking), and a short scripting outlook pointing to the
  future 05-automation-scripting module. All facts verified against Ghidra
  12.1.2 source/docs by a research pass; sourcing kept in
  `01-core-workflows/RESEARCH-NOTES.md`.

## Carried-forward notes

- Git remote uses **SSH** (`git@github.com:mrolappe/ghidra-tutor.git`). An
  earlier session switched to HTTPS because SSH push failed, but the actual
  cause was KeePassXC's ssh-agent having a locked database (no key
  available) — not a missing SSH setup. Remote is back on SSH; if push
  fails again, check KeePassXC is unlocked before changing the remote.
- Default branch is `main`. GitHub repo: https://github.com/mrolappe/ghidra-tutor (public, owner `mrolappe`).
- The 7 module folders + `exercises/.gitkeep` placeholders already exist —
  later phases only add files into them, no need to `mkdir` again.
- Guides are pinned to **Ghidra 12.1.2** (current stable as of Phase 1
  research) — keep later phases on the same version unless the user says
  otherwise, so shortcuts/menu paths stay consistent across modules.
- A few Phase 1 facts couldn't be confirmed from docs/source and are
  flagged in `00-quickstart/RESEARCH-NOTES.md` under "Unresolved": exact
  wording of the first-open "analyze now?" dialog, the bookmark-creation
  shortcut (none found bound in source — right-click is the documented
  path), and a discrepancy where source binds Ctrl+Shift+F to "Show
  References To" but the printed Cheat Sheet doesn't list a shortcut for it.
  Sanity-check these against an installed copy when convenient.
- Sample binaries for **00-quickstart** exercises are plain, host-native C
  compiled with the system `cc`/`gcc`/`clang` + `strip` (see
  `exercises/02-first-import-analysis/sample/build.sh`) — no cross-assembler
  involved, since this module isn't platform-specific. That's specific to
  00-quickstart and 01-core-workflows; retro modules (02–04) switch to
  vasm/vbcc/vlink (68000) or cc65 (6502) per the plan's legal note — don't
  reuse the plain-`cc` pattern there.
- Built artifacts (`*.bin`, `*.o`) and local Ghidra project state (`*.gpr`,
  `*.rep/`) are gitignored (root `.gitignore`, added Phase 2) — only source
  (`sample.c`, `build.sh`) is committed; later modules' sample/ folders
  should follow the same source-only convention.
- A few Phase 3 facts couldn't be fully confirmed and are flagged in
  `01-core-workflows/RESEARCH-NOTES.md` under "Unresolved": the
  `Ctrl+Shift+D` "Edit Data Type" and `Alt+R` "Create Default Reference"
  shortcuts (taken from help-doc prose, not a `KeyBindingData` call in
  source), the Script Manager's open-shortcut and "Rerun Script"
  (Ctrl+Shift+R, Cheat-Sheet-sourced only), and `FunctionIDDebug.html`
  (fetched but not reviewed — low-level FID troubleshooting, judged
  out of scope). Sanity-check against an installed copy when convenient.
- `02-decompiler-tuning.md` notes a naming surprise worth remembering: on
  x86-64-win, Ghidra's *default* calling convention is internally named
  `__fastcall` in the `.cspec` — it's the Microsoft x64 convention, not the
  32-bit fastcall the name suggests. Don't assume convention names carry
  their common meaning across architectures.

## Next

- Phase 4 — 01-core-workflows: Exercises + click-to-annotate HTML demo
  - Content: `exercises/<slug>/{problem.md, solution.md}` for the 6
    Phase 3 topics (data types & structures, decompiler tuning, control-flow/
    reference analysis, FID, version tracking, scripting outlook — though the
    last is a preview, not exercise material, so likely only 5 exercise
    sets), plus a "click-to-annotate" interactive HTML demo on a sample
    Decompiler output (click a variable → explanation), per PLAN.md's
    visual/interactive materials table.
  - Model: Sonnet 5.
  - Follow the 00-quickstart Phase 2 convention: prefer one continuous
    sample program shared across exercises over several throwaway ones,
    plain host-native C (`cc`/`gcc`/`clang` + `strip`, no cross-assembler —
    01-core-workflows isn't platform-specific), source-only committed
    (`sample.c`/`build.sh`, gitignore covers build artifacts).
  - Open items carried from Phase 1 and Phase 3 (see notes above): several
    facts are flagged "verify on an installed copy" rather than fully
    source-confirmed — worth a sanity check once Ghidra is actually
    installed and running, whenever convenient (not blocking).
