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

- Phase 4 — 01-core-workflows: Exercises + click-to-annotate HTML demo.
  Added `exercises/<slug>/{problem.md, solution.md}` for all 5 Phase 3
  topics (`01-data-types`, `02-decompiler-tuning`,
  `03-control-flow-references`, `04-function-id`, `05-version-tracking` —
  `06-scripting-outlook` stayed preview-only, no exercise, per the Phase 3
  note). Exercises 01–03 share one continuous sample program
  (`exercises/sample/{sample.c, build.sh}`, an `Item` struct + a
  function-pointer array) so the struct/decompiler-tuning/control-flow
  exercises chain the way 00-quickstart's did. `04-function-id` and
  `05-version-tracking` each need their own binary *pairs* (a custom FID
  database needs a "reference" and "target" binary sharing library code; VT
  needs two versions of one program), so they get their own `sample/`
  subfolders instead of reusing the shared one. Added
  `01-core-workflows/click-to-annotate-demo.html` (self-contained, no
  dependencies): a hand-transcribed "before annotation" Decompiler view of
  the shared sample's three functions, with clickable tokens explaining
  Ghidra's default-naming conventions and cross-linking back to the guides
  and exercises that fix each one.

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
- Phase 4 pattern for exercises needing more than one related binary: don't
  force everything into the module's one shared `sample/` folder — Function
  ID needs a *pair* of independently-built binaries sharing library code
  (`04-function-id/sample/{lib.c, reference.c, target.c, build.sh}` →
  `reference.bin`/`target.bin`), and Version Tracking needs two *versions*
  of one program (`05-version-tracking/sample/{v1.c, v2.c, build.sh}`).
  Give an exercise its own `sample/` subfolder whenever its pedagogical
  point specifically requires more than one binary; keep using the shared
  module-level `sample/` for exercises that just need one program with
  interesting structure.
- `01-core-workflows/click-to-annotate-demo.html` shows Decompiler output
  that's **hand-transcribed** (representative of what Ghidra would show,
  not a captured real decompile) since Ghidra isn't installed/scriptable in
  this environment — flagged as such in the HTML itself. If a later module's
  interactive HTML needs real tool output (e.g. actual register values,
  actual memory maps), reconsider whether hand-transcription is still
  honest enough or whether it needs an "illustrative only" disclaimer too.

- Phase 5 — 02-retro-amiga: Guides + diagram. Added
  `02-retro-amiga/README.md` (module index + Mermaid Hunk-block-sequence
  diagram) and five guides: 68000 recap (registers incl. A7 banking,
  big-endian, addressing modes as Ghidra prints them, MOVEM/LINK-UNLK/TRAP
  patterns), Amiga Hunk executable format (block types/layout, and that
  **Ghidra ships no native Hunk loader** — verified against the source tree,
  community extension `BartmanAbyss/ghidra-amiga` noted as the practical
  option), exec.library/Kickstart basics (SysBase at address `4`, LVO
  jump-table mechanics, why `jsr -552(a6)` shows up unnamed in Ghidra),
  custom chip registers (Agnus/Denise/Paula register table from AHRM
  Appendix B, read/write-address asymmetry), and typical copy-protection
  patterns (non-standard track formats, CIA-timer timing checks, keydisk
  schemes, anti-disassembly obfuscation, trap-door bootstrap loaders — RE
  recognition framing, sourced from Amiga preservation material, not a
  cracking how-to). All facts verified by a research pass against primary
  sources (Motorola/NXP M68000 PRM, Amiga Hardware Reference Manual, Amiga
  ROM Kernel Reference Manual, the literal AmigaOS NDK `doshunks.h`, and
  Ghidra 12.1.2 source directly — not secondary summaries); sourcing kept in
  `02-retro-amiga/RESEARCH-NOTES.md`.

## Carried-forward notes (continued)

- **Ghidra has no native Amiga/Hunk loader** (confirmed against the
  `Ghidra_12.1.2_build` source tree: no Hunk-related `Loader` class, no
  `hunk`/`amiga` hits repo-wide, `68000.opinion` doesn't pair 68000 with a
  Hunk loader). Phase 6 exercises for this module will need either the
  community extension `BartmanAbyss/ghidra-amiga` (unverified internals —
  worth reviewing before recommending it hands-on) or a manual
  raw-binary-import workaround per hunk. Decide which before writing an
  exercise that has learners actually import a Hunk binary.
- `OpenLibrary`'s LVO (`-552`) is well-corroborated across secondary sources
  but wasn't pinned to the literal NDK `.fd`/pragma file in Phase 5's
  research pass — flagged in `02-retro-amiga/RESEARCH-NOTES.md` under
  Unresolved, not blocking but worth a check if Phase 6 needs more LVO
  constants than just this one example.

## Next

- Phase 6 — 02-retro-amiga: Exercises + Custom-Chip/Register-Explorer HTML
  - Content per PLAN.md: `exercises/<slug>/{problem.md, solution.md}` for
    the 5 Phase 5 topics, using self-assembled 68000 samples (vasm/vbcc or
    vasm+vlink — NOT the plain-`cc` pattern from 00-quickstart/
    01-core-workflows, see the platform-toolchain note above) or
    public-domain/homebrew/demoscene material — no copyrighted ROMs/games.
    Plus the interactive HTML: a custom-chip/register explorer (hover/click
    an address range → chip + function), per PLAN.md's visual/interactive
    materials table (`02-retro-amiga` row).
  - Model: Sonnet 5.
  - Before scripting an exercise that imports a real Hunk binary, resolve
    the open item above (which loader path — `ghidra-amiga` extension vs.
    manual raw-binary import per hunk).
  - Open items carried from Phase 1 and Phase 3: several quickstart/
    core-workflows facts are still flagged "verify on an installed copy" —
    not blocking, worth a sanity check whenever Ghidra is actually running.
