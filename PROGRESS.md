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

- Phase 6 — 02-retro-amiga: Exercises + Custom-Chip-Register-Explorer HTML.
  Added `exercises/<slug>/{problem.md, solution.md}` for all 5 Phase 5
  topics (`01-68000-recap`, `02-hunk-executable-format`,
  `03-exec-library-kickstart`, `04-custom-chip-registers`,
  `05-copy-protection-patterns`). Exercises 01/03/04 share one hand-written
  68000 assembly program (`exercises/sample/sample.s`, vasm Motorola
  syntax) built two ways by `exercises/sample/build.sh`: a flat binary
  (`sample.bin`, `-Fbin`) for direct Raw Binary import, and a real Hunk
  executable (`sample.hunk`, `-Fhunk` + `vlink -bamigahunk`) so exercise 02
  can walk genuine `HUNK_*` block IDs by hand with `od`/hex viewer — no
  Ghidra loader needed for that one. Exercise 05 (copy-protection patterns)
  uses three invented pseudo-disassembly snippets instead of a sample
  binary (no real protected disks; recognition exercise, per the module's
  framing). Resolved the open loader-decision item from Phase 5: checked
  `BartmanAbyss/ghidra-amiga`'s GitHub releases via `gh api` — actively
  maintained (latest tag `20260128`), but each release build targets one
  specific Ghidra point release (currently 12.0.1, not this course's
  pinned 12.1.2); exercise 03 documents this version gap directly and
  treats the extension as optional/Part B, with Part A doing the LVO
  pattern-recognition manually via raw import (no loader dependency at
  all). Added `02-retro-amiga/custom-chip-register-explorer.html`
  (self-contained, no dependencies): a clickable $DFF000–$DFF11F register
  map color-coded by chip (Agnus/Denise/Paula, jointly-owned registers
  shown as a diagonal split) plus a filterable/sortable table view: colors
  taken from the dataviz skill's validated 3-slot categorical palette
  (blue/orange/aqua — passes all-pairs CVD checks in both light and dark
  in both modes without needing a 4th color for "joint"). Verified with a
  headless Playwright render (41 register cells, 41 table rows, click and
  filter both functional, zero console/page errors, light+dark
  screenshots checked) since no browser interaction is otherwise possible
  in this environment.

## Carried-forward notes (continued)

- **No 68000 toolchain (`vasm`/`vlink`) is installed in this session's
  environment** — `exercises/sample/build.sh` (Phase 6) is written to the
  documented vasm/vlink CLI syntax but has **not** been run/verified end to
  end, unlike 00-quickstart/01-core-workflows' `cc`-based `build.sh`
  scripts which were actually executed. Flagged in the script's own
  comment. Worth an actual build+import sanity check against a real
  install before trusting exact byte offsets; exercises were deliberately
  written to ask students to locate patterns by mnemonic/structure, not by
  hardcoded addresses, so they should survive minor assembler-output
  differences regardless.
- **`ghidra-amiga` version-pinning**: confirmed (Phase 6, via `gh api
  repos/BartmanAbyss/ghidra-amiga/releases`) that each release build
  targets one specific Ghidra point release, currently 12.0.1 — a
  minor-version gap against this course's pinned 12.1.2. If a later phase
  (03-retro-atari-st or 04-retro-c64) needs a similar community-extension
  recommendation, check its releases the same way rather than assuming a
  prebuilt zip matches the pinned Ghidra version.
- **DMACON/INTENA/INTREQ "SET/CLR" bit-15 write convention** (verified
  Phase 6, added to `RESEARCH-NOTES.md`'s Phase 6 addendum, not yet folded
  into `04-custom-chip-registers.md` itself): bit 15 of a written word
  selects set-vs-clear for whichever other bits are `1`; this is
  independent of and worth distinguishing from individual bit-name tables
  like `DMAEN` (bit 9 of `DMACON`, not previously verified in Phase 5).
- **`ghidra-amiga` internals are still unverified** (loader class,
  relocation-resolution timing, one-block-per-hunk-or-not) — Phase 6's
  exercise 03 works around this by treating the extension as optional and
  keeping the primary path loader-independent; still worth a closer look
  if a future phase wants to lean on the extension more directly.

- **Ghidra has no native Amiga/Hunk loader** (confirmed against the
  `Ghidra_12.1.2_build` source tree: no Hunk-related `Loader` class, no
  `hunk`/`amiga` hits repo-wide, `68000.opinion` doesn't pair 68000 with a
  Hunk loader) — see the `ghidra-amiga` notes above for how Phase 6's
  exercises worked around this.
- `OpenLibrary`'s LVO (`-552`) is well-corroborated across secondary sources
  but wasn't pinned to the literal NDK `.fd`/pragma file in Phase 5's
  research pass — flagged in `02-retro-amiga/RESEARCH-NOTES.md` under
  Unresolved, not blocking but worth a check if a later phase needs more
  LVO constants than just this one example.

- Phase 7 — 03-retro-atari-st: Guides + diagram. Added
  `03-retro-atari-st/README.md` (module index + Mermaid PRG/TOS header +
  segment-layout diagram, offsets from the header table) and three guides:
  68000/TOS differences from Amiga (no fixed SysBase-at-address-4
  equivalent — GEMDOS hands each process a basepage pointer on the stack
  instead; full basepage field table; `Mshrink()` stack-shrink convention;
  `Super()`/user-supervisor mode as a genuine RE signal on this platform,
  unlike Amiga's ungated custom chips), GEMDOS/BIOS/XBIOS call recognition
  (TRAP #1/#13/#14, stack-based calling convention, caller cleans the
  stack, unnamed-opcode problem structurally identical to Amiga's unnamed
  LVO calls), and PRG/TOS executable format (28-byte header field table,
  `PRGFLAGS` bits, `ABSFLAG`'s known-incorrect-on-some-TOS-versions trap,
  fixup-stream encoding, no separate entry-point field — always byte 0 of
  TEXT). Confirmed **Ghidra 12.1.2 has no native PRG/TOS loader either**
  (same check method as Phase 5's Hunk-loader check: full `Loader` class
  listing plus full-tree `atari`/`gemdos`/`prg` search, both negative;
  `68000.opinion` only pairs 68000 with ELF/PEF/Palm/a.out) — but unlike
  Amiga's `ghidra-amiga` extension (a full Loader extension needing a
  Ghidra-point-release match), the Atari-side community option
  (`czietz/ghidraScripts_for_Atari`) is plain Ghidra scripts with no
  build/install step, so the guide frames it as a lighter-weight workaround
  rather than reusing the Amiga extension story unchanged. All facts
  verified against The Atari Compendium (with its "not for public
  distribution" draft-copy caveat flagged and FreeMiNT's `tos.hyp`
  preferred as the citable link) and Ghidra 12.1.2 source directly;
  sourcing kept in `03-retro-atari-st/RESEARCH-NOTES.md`.

- Phase 8 — 03-retro-atari-st: Exercises. Added
  `exercises/<slug>/{problem.md, solution.md}` for all 3 Phase 7 topics
  (`01-amiga-atari-differences`, `02-gemdos-bios-xbios-calls`,
  `03-prg-tos-executable-format`). No dedicated interactive HTML for this
  module, per PLAN.md's visual-materials table (Amiga/Atari share one row —
  Phase 6's Custom-Chip-Register-Explorer). Exercises 01/02 share one
  hand-written 68000 program (`exercises/sample/sample.s`, vasm Motorola
  syntax) demonstrating the basepage-read pattern plus two already-verified
  GEMDOS `TRAP #1` calls (`Mshrink` `$4A`, `Super` `$20` — reused straight
  from the Phase 7 guide's own sourced snippets rather than researching new
  BIOS/XBIOS opcode numbers for the sample, since one verified GEMDOS
  TRAP-call pattern is enough to teach the recognition shape). Exercise 03
  needs a real PRG header to hex-walk by hand (same no-Ghidra-loader
  treatment Phase 6 gave the Hunk block walk), so `sample.s` is deliberately
  code-only (no data/bss section) — keeps `PRG_dsize`/`PRG_bsize`/the fixup
  chain all cleanly zero, so the exercise's computed values don't depend on
  a real build to state expected answers.

- Phase 9 — 04-retro-c64: Guides + diagram. Added `04-retro-c64/README.md`
  (module index + Mermaid PRG-load diagram: 2-byte header → data loaded at
  that address → BASIC `SYS` stub → ML payload runs) and five guides:
  6502/6510 recap (registers, addressing modes as Ghidra actually prints
  them per `6502.slaspec`, fixed `$0100`-`$01FF` stack page,
  NMI/RESET/IRQ vectors and default `ZERO_PAGE`/`STACK` blocks per
  `6502.pspec`, and the key platform fact — Ghidra ships only
  `6502:LE:16:default`/`65C02:LE:16:default`, **no separate 6510
  variant**, so the 6510's `$00`/`$01` I/O port is invisible to Ghidra's
  processor spec and shows up as plain zero-page RAM), memory map +
  bank switching (full RAM/ROM/I-O view tables, `$00`/`$01` control-line
  bit weights, condensed 7-row no-cartridge mode table, default mode 31),
  KERNAL/BASIC-ROM references (complete 40-entry `$FF81`-`$FFF3` jump
  table with names, same unnamed-call recognition problem as Amiga
  LVOs/Atari `TRAP`s), PRG/cartridge formats (PRG's 2-byte load-address
  header; CRT's 16-byte file header + `CHIP`-packet structure, both
  tables derived directly from VICE Manual §17.14's own documented hex
  dump), and VIC-II/SID registers (full `$D000`-`$D02E` and
  `$D400`-`$D418` tables). Confirmed **Ghidra 12.1.2 has no native
  PRG/CRT loader** (checked via `unzip -l` against the shipped `.jar`s
  rather than source, since this distribution ships compiled loaders —
  first module to need that method instead of grepping `.java`; zero
  C64/Commodore/PRG/cartridge-named classes anywhere) and **no
  `.opinion` file at all under `Processors/6502/`** (unlike 68000, not
  even pre-wired to a loader pairing). Checked two community options via
  `gh api`: `jamesham/ghidra-commodore` (has a real `CommodoreCartridgeLoader`
  for CRT, but zero releases, last commit 2022-01-03, source-only build,
  and no PRG loader at all) and `tom-seddon/Ghidra6502` (CPU-description/
  analyzer improvements, not a loader; zero releases, last push
  2020-07-17, Eclipse-project-only install) — both flagged as
  real-but-uncertain rather than recommended, a stricter caveat than
  Phase 5/7 gave `ghidra-amiga`/`ghidraScripts_for_Atari`. All facts
  verified against Ghidra 12.1.2's `.ldefs`/`.pspec`/`.slaspec` files and
  `.jar` contents directly, c64-wiki.com's own HTML tables (parsed
  programmatically, not paraphrased), `sta.c64.org`'s standard KERNAL
  function reference, and the VICE Emulator Manual; sourcing kept in
  `04-retro-c64/RESEARCH-NOTES.md`.

- Phase 10 — 04-retro-c64: Exercises + Memory-Map-Explorer HTML. Added
  `exercises/<slug>/{problem.md, solution.md}` for all 5 Phase 9 topics
  (`01-6502-6510-recap`, `02-memory-map-bank-switching`,
  `03-kernal-basic-rom-references`, `04-prg-cartridge-formats`,
  `05-vic-sid-registers`). Exercises 01/02/03/05 share one hand-written
  6502 program (`exercises/sample/sample.s`, ca65 syntax) built by
  `exercises/sample/build.sh` into a real PRG (`sample.prg`) — covering an
  addressing-mode tour, a bank-switch `$01` write (chosen as `$36` so
  `HIRAM` stays set and the following `JSR $FFD2` remains valid — a
  deliberately internally-consistent example, unlike the illustrative-only
  Amiga/Atari samples), a `CHROUT` KERNAL call, and VIC-II border-color +
  SID voice-1-note pokes, so one shared disassembly carries four of the
  five topics (mirroring Phase 6's maximal-sharing approach, and unlike
  Amiga's copy-protection exercise, VIC-II/SID needed no invented
  pseudo-disassembly since real register pokes involve no copyrighted
  material). Exercise 04 (PRG/cartridge) hand-walks the same built PRG's
  2-byte load-address + tokenized-BASIC-`SYS`-stub header empirically
  (deriving the SYS target from the student's own hex dump rather than
  asserting cc65's exact `__EXEHDR__` output, which wasn't run/verified —
  see Carried-forward notes), plus a Part B hand-walking the CRT format
  using the guide's own already-cited VICE-manual example dump (no build
  needed for that half). Resolved the open toolchain-shape question from
  Phase 9's Next-notes: confirmed via cc65's own docs (`cl65.html`,
  `c64.html` §4.2) that `cl65 -t c64 -C c64-asm.cfg -u __EXEHDR__` is a
  **single-step** build for an assembly-only `.s` file (no separate
  ca65+ld65 pass needed), the same single-step shape Phase 8 found for
  `vasmm68k_mot -Ftos`. Added
  `04-retro-c64/memory-map-explorer.html` (self-contained, no
  dependencies): the full `$0000`-`$FFFF` map as a labeled block list plus
  a mode selector reproducing the guide's condensed 7-row, no-cartridge
  (`GAME=EXROM=1`) bank-switching table — selecting a mode recolors
  `$A000`-`$BFFF`/`$D000`-`$DFFF`/`$E000`-`$FFFF` live; `$8000`-`$9FFF`
  stays RAM throughout (cartridge-only override, out of this selector's
  documented scope) — plus a filterable/sortable table of the guide's
  three static reference tables (RAM/ROM/I-O views). Used a 5-slot
  categorical palette (RAM/BASIC ROM/KERNAL ROM/Char ROM/I-O) from the
  dataviz skill's validated 8-hue set, checked with
  `scripts/validate_palette.js` in both light and dark mode (all hard
  gates pass; the expected light-mode contrast WARN on 3 slots is
  mitigated since every block already carries a direct text label plus
  the table view). Verified with a headless Playwright render (9 map
  rows, 20 table rows, 7 mode options, mode-change confirmed to actually
  recolor the dynamic rows, filter functional, zero console/page errors,
  light+dark screenshots checked) — same verification method Phase 6
  used, run from a sibling project (`~/studio/playwright-lernen`) since
  this project itself has no `node_modules`.

## Next

- Phase 11 — 05-automation-scripting: Guides + Diagram + Exercises
  - Content per PLAN.md: Script Manager + Java-API basics, Jython
    scripting, Ghidrathon (Python 3) as the modern path, Headless Analyzer
    for batch processing — plus a Mermaid sequence diagram of the Headless
    Analyzer flow, and exercises/solutions. PLAN.md's phase table bundles
    guides+diagram+exercises into one phase here (unlike the two-phase
    guides/exercises split used for every module so far) — re-split at
    the start of the session if it turns out too large for one sitting,
    per PLAN.md's own note that the table is a starting split, not a
    rigid requirement.
  - Model: Sonnet 5.
  - This module is platform-agnostic (not tied to Amiga/Atari/C64) — it
    can reuse any already-built sample binary from earlier modules for its
    scripting-exercise targets rather than building a new one; check
    00-quickstart's or 01-core-workflows's plain-`cc`-built samples first
    since those were actually compiled/verified in this environment,
    unlike the retro modules' unverified vasm/cc65 builds.
  - `01-core-workflows/06-scripting-outlook.md` already exists as a short
    preview pointing forward to this module — read it first so 05's
    guides pick up from where it left off rather than re-covering the
    same ground.

## Carried-forward notes (continued)

- **Atari Compendium distribution caveat** (Phase 7): the primary Atari-
  world source used for this module's facts (TRAP numbers, PRG header
  offsets, basepage struct, opcode tables) carries a "not for public
  distribution" notice on its own title page — a 1992 author draft-review
  copy, openly mirrored across the Atari community for decades but never
  formally re-released. Guides cite the *facts* (numbers, offsets, table
  entries) rather than link to or bundle the PDF itself; prefer linking
  `freemint.github.io/tos.hyp` (actively maintained, openly hosted,
  independently cross-checked at least one TRAP number against it) when a
  single canonical link is needed. Keep this in mind if a later phase
  wants to cite the Compendium again.
- **`czietz/ghidraScripts_for_Atari` internals unverified** (Phase 7, same
  treatment Phase 6 gave `ghidra-amiga`): confirmed to exist and to
  provide `ImportAtariPRG.py`/`ImportAtariTOSROM.py`/a MiNTLib FID
  database via its README, but the actual Python source (exact fixup-
  stream handling, whether TEXT/DATA/BSS become separate memory blocks)
  wasn't reviewed. Worth a closer look once Phase 8's exercises actually
  need to recommend/use it.
- **Open question, not settled by a primary source** (Phase 7): whether
  classic single-tasking `Pexec()` switches the CPU to user mode before
  jumping to a freshly loaded program, or leaves it in whatever mode it
  inherited and relies on the program calling `Super()` itself. Flagged
  as Unresolved in `03-retro-atari-st/RESEARCH-NOTES.md` rather than
  asserted either way in the guide text. A future pass could resolve this
  by reading EmuTOS's (GPL'd, source-available) `Pexec()` implementation
  directly.
- **`vasmm68k_mot -Ftos` builds a real PRG in one step, no `vlink` needed**
  (Phase 8, confirmed via a documented toolchain-setup command — not
  guessed): unlike Amiga's Hunk build, which needs a separate
  `vlink -bamigahunk` link pass, a single-object-file Atari program can go
  straight from `.s` to `.prg`/`.tos` with one `vasmm68k_mot -Ftos` call.
  `exercises/sample/build.sh` uses this for `sample.prg`; still flagged
  unverified/not-run like Phase 6's script, since no 68000 toolchain is
  installed in this session's environment — but the *command shape* itself
  is sourced, not assumed. Worth checking whether cc65 (Phase 9/10's C64
  toolchain) has a similarly simpler single-step path before assuming it
  needs a separate link step too.

- **Ghidra has no separate 6510 language ID** (Phase 9, confirmed directly
  from `6502.ldefs`): only `6502:LE:16:default` and `65C02:LE:16:default`
  exist. Every C64 exercise/sample in Phase 10 should expect a plain
  6502 import — don't look for or reference a "6510" processor ID
  anywhere in exercise instructions, it doesn't exist in this Ghidra
  version.
- **PRG import = manual Raw Binary at the header's load address, always**
  (Phase 9): confirmed no built-in or reliably-installable community PRG
  loader exists (see Phase 9's Completed entry above for the
  `ghidra-commodore`/`Ghidra6502` caveats). Phase 10's PRG-format exercise
  should walk this manually — read the first 2 bytes as little-endian
  load address, import the rest as Raw Binary at that address — the same
  "no loader, hand-walk the header" treatment Phase 6 gave Hunk and
  Phase 8 gave PRG/TOS.
- **CRT/cartridge loader situation is weaker than Amiga's/Atari's
  community options** (Phase 9): `jamesham/ghidra-commodore`'s
  `CommodoreCartridgeLoader` exists but has zero tagged releases (source-
  only, last commit 2022-01-03) — don't recommend it as a turnkey install
  the way Phase 6/7 could recommend `ghidra-amiga`/`ghidraScripts_for_Atari`.
  If Phase 10 wants a CRT-format exercise, treat it as a hand-walked
  header exercise (field tables are in
  `04-retro-c64/04-prg-cartridge-formats.md`) rather than assuming a
  working loader extension.
- **Loader-absence checks against a binary distribution use `unzip -l` on
  the shipped `.jar`s, not `grep` on `.java` source** (Phase 9): this
  session's `~/ghidra_12.1.2_PUBLIC` install ships compiled loader
  classes only (`Ghidra/Features/Base/lib/Base.jar` etc.), unlike the
  full source checkout the Amiga/Atari modules apparently had access to.
  If a later phase needs another loader-absence check, `unzip -l
  <jar> | grep -i opinion/.*Loader.class` (plus a cross-jar substring
  search for platform-specific keywords) is the working method here.
- **c64-wiki.com's default `$00`/`$01` power-up byte values ($37`/`$2F`,
  commonly cited elsewhere) weren't confirmed against a fetched source in
  Phase 9** — only the *behavior* (bits 0-2 output by default, mode 31
  selected) is sourced. Flagged Unresolved in
  `04-retro-c64/RESEARCH-NOTES.md`; worth confirming before stating the
  literal byte values in a later phase's exercise solution.

- **`cl65 -t c64 -C c64-asm.cfg -u __EXEHDR__` is a single-step, no-C-
  runtime PRG build** (Phase 10, confirmed via cc65's own `cl65.html` and
  `c64.html` §4.2, not guessed): `c64-asm.cfg` is cc65's linker config
  specifically for assembler-only programs (skips the C runtime/`crt0`),
  and `-u __EXEHDR__` forces linking just the small BASIC-`SYS`-stub
  module on top, still in one `cl65` call — no separate `ca65`+`ld65`
  pass needed for a single source file, matching the shape Phase 8 found
  for `vasmm68k_mot -Ftos`. `exercises/sample/build.sh` uses this, but —
  like every retro-module toolchain script so far — is **unverified/not
  run**, since no cc65 install exists in this session's environment.
- **The exact bytes `__EXEHDR__` emits (the tokenized BASIC line's link-
  address, line number, and specifically *which* decimal SYS-target
  address it embeds) are determined by the linker at build time and
  weren't asserted as fixed values** (Phase 10) — cc65's docs describe the
  mechanism (a small BASIC stub using `SYS`) but not its literal byte
  output, and no cc65 install was available to inspect it directly.
  `exercises/04-prg-cartridge-formats`'s Part A is written to have the
  student derive these values empirically from their own build's hex
  dump instead of checking them against an assumed literal sequence —
  worth keeping this "derive from your own build, don't assert cc65
  internals" framing if a later phase adds more cc65-based exercises.
- **BASIC tokenization mechanics used for that exercise are independently
  sourced** (Phase 10, c64-wiki.com's "BASIC token" page and
  codebase64.net's SYS-stub walkthrough, cross-checked against each
  other): `$9E` = the `SYS` token; a stored BASIC line is
  link-pointer(2, LE) + line-number(2, LE) + tokens/text + `$00`
  end-of-line, with the *next* line's link-pointer value pointing at
  that line's own start — a program's last line signals "end" via a
  `$0000` link pointer in that same slot. These facts are platform-
  general (any C64 BASIC program), not cc65-specific, so they're safe to
  reuse without the "unverified toolchain" caveat above.
- **Amiga's/Atari's "each guide topic gets its own sample-sharing
  strategy" pattern extended cleanly to a 4th platform**: C64's shared
  `exercises/sample/sample.s` covers 4 of 5 topics (recap, bank-switching,
  KERNAL, VIC-II/SID) in one small program, since none of those needed
  copyrighted material — only the PRG/cartridge-format topic needed
  something built (the same program, for its header) plus a from-the-guide
  worked example (CRT, no build). No topic in this module needed Amiga's
  "invented pseudo-disassembly" treatment (that was specific to
  copy-protection, which has no real ethical/legal C64 equivalent in this
  module's topic list).
- **dataviz-skill palette validation + headless-Playwright rendering are
  both repeatable checks worth reusing as-is** for any later interactive
  HTML: `node scripts/validate_palette.js "<hex,...>" --mode
  light|dark --surface <hex>` (run from the dataviz skill's own directory)
  for color-accessibility gates, and a short Playwright script (chromium,
  `colorScheme: 'light'|'dark'`, check `pageerror`/console `error` events,
  exercise any interactive controls, screenshot both themes) for
  behavioral/rendering verification. This project itself has no
  `node_modules`; Phase 10 ran the Playwright check from a sibling project
  (`~/studio/playwright-lernen`) that already has the package installed —
  worth checking for a similar sibling install (or a global one) before
  assuming Playwright needs a fresh `npm install` in a later phase.
