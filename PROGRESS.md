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

## Next

- Phase 3 — 01-core-workflows: Guides + diagram
  - Content: Data Types & Structures, Decompiler-Tuning (Calling
    Conventions, Function Signatures), Control-Flow/Reference-Analyse,
    Function ID (FID) databases/signatures, Version Tracking basics, short
    outlook to scripting (deferred to 05). Plus the
    Bytes→P-Code→Decompiler-Output Mermaid diagram.
  - Model: Sonnet 5.
  - Open items carried from Phase 1 (see notes below): a few facts are
    still flagged "verify on an installed copy" rather than fully
    source-confirmed — worth a quick sanity check once Ghidra is actually
    installed and running, whenever convenient (not blocking).
