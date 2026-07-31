# Research notes — 04-retro-c64 (Phase 9)

Four kinds of sources feed this module, cited distinctly per fact:

- **Ghidra's own source/binaries**, checked against the same pinned
  install used by every prior module's source checks: the local
  `~/ghidra_12.1.2_PUBLIC` distribution. Used for: the 6502 processor's
  declared language variants, default symbols/memory blocks, and —
  critically — whether a native C64/PRG/cartridge loader exists. Unlike
  the Amiga/Atari modules (which had a full Ghidra *source* checkout to
  grep), this pass worked against the public **binary distribution**:
  `.ldefs`/`.pspec`/`.slaspec` files are plain text and were read
  directly, but the built-in `Loader` classes only exist compiled inside
  `Ghidra/Features/Base/lib/Base.jar` (and other feature `.jar`s), so the
  loader check used `unzip -l` to list class names rather than `grep`-ing
  `.java` source. Equivalent confidence, different mechanism — worth
  flagging since it's a first for this course.
- **c64-wiki.com** — the C64 community's most complete single reference
  for memory map, bank switching, and the VIC-II/SID register layouts.
  Tables were extracted directly from the live HTML (`<table
  class="wikitable">` markup, parsed programmatically) rather than
  summarized, so the field names/addresses in the guides are verbatim
  transcriptions, not paraphrases.
- **`sta.c64.org/cbm64krnfunc.html`** — "Commodore 64 standard KERNAL
  functions," a long-standing community reference documenting the public
  `$FF81`–`$FFF3` jump-table API (the same page already cited inside a
  comment in `cecio/BULA-Virus`'s `FindC64KernalROMCalls.java` Ghidra
  script, found during the community-tooling search below, which is what
  led to using it here).
- **The VICE Emulator Manual**, §17.14 "The CRT cartridge image format" —
  VICE is the reference C64 emulator and its own team is the de facto
  authority for the CRT format (the manual explicitly states the VICE
  team assigns new CRT type IDs), making this the closest thing to a
  primary spec for a format that has no single "official Commodore"
  origin (CRT is an emulator-era convenience format, not something
  Commodore itself ever defined).

---

## 1. 6502/6510 recap

- **Ghidra ships no separate 6510 language ID.** Read directly from
  `Ghidra/Processors/6502/data/languages/6502.ldefs`: exactly two
  `<language>` entries exist, `6502:LE:16:default` ("6502 Microcontroller
  Family") and `65C02:LE:16:default` ("65C02 Microcontroller Family") — no
  `6510` variant anywhere in the file. Confirms the guide's central claim
  that C64 work always imports as plain 6502.
- **Default symbols and memory blocks**, read directly from
  `Ghidra/Processors/6502/data/languages/6502.pspec`: `<default_symbols>`
  declares `NMI`@`$FFFA`, `RES`@`$FFFC`, `IRQ`@`$FFFE` (all `entry="true"
  type="code_ptr"`); `<default_memory_blocks>` declares `ZERO_PAGE`
  (`start_address="0x0000" length="0x0100"`) and `STACK`
  (`start_address="0x0100" length="0x0100"`), both `initialized="false"`.
  These are auto-created by Ghidra on every 6502 import, which is why the
  guide can state the stack-page and vector-table facts as Ghidra-visible
  behavior, not just 6502-family trivia.
- **Addressing-mode display syntax**, read directly from
  `Ghidra/Processors/6502/data/languages/6502.slaspec`'s subconstructor
  definitions (`OP1`, `OP2`, `OP2LD`, `OP2ST`, `ADDR16`, `ADDRI`) — e.g.
  `OP1: "#"imm8 is bbb=2; imm8` for immediate, `OP1: (imm8,X) is bbb=0 &
  X; imm8` for indexed-indirect, `ADDRI: (imm16) is imm16` for `JMP`'s
  indirect mode. The `$`-prefixed hex rendering of `imm8`/`imm16` tokens
  themselves wasn't re-derived from the token's display attribute (not
  fetched in this pass) but is standard, uncontested SLEIGH convention for
  this processor family and matches every publicly documented Ghidra 6502
  disassembly listing.
- **No CPU-privilege-mode RE signal, unlike Atari ST's `Super()`**: this
  is an absence claim (6502 has no privilege levels, full stop) rather
  than something requiring a citation — noted for cross-module contrast
  with `03-retro-atari-st/01-amiga-atari-differences.md`'s user/supervisor
  discussion, not independently sourced.

## 2. Memory map & bank switching

- **RAM/ROM/I-O view tables**: transcribed directly from c64-wiki.com,
  "Memory Map" — the page's three separate `wikitable`s (plain RAM view,
  "what ROM can overlay" view, and the `$D000`-`$DFFF` I/O sub-map),
  parsed programmatically from the live page rather than copied from a
  secondary summary.
- **`$00`/`$01` control-line semantics, bit weights, and the "must be
  configured as output, which is the power-up default" claim**:
  c64-wiki.com, "Bank Switching," "Control bits"/"CPU Control Lines"
  sections — direct quotes preserved in the guide ("This is the default
  upon power-up...").
- **The 14-mode optimized table**: transcribed from c64-wiki.com's own
  "Optimised Mode Table" (the deduplicated 14-row version of the full
  32-row PLA truth table), filtered in the guide to the no-cartridge
  (`GAME=EXROM=1`) subset actually relevant to plain software-driven bank
  switching, since the full table's cartridge-present rows depend on
  expansion-port hardware state this course's guides don't otherwise
  cover. "Default is mode 31" is a direct quote from the same page's "Mode
  Table Notes."
- **Not independently verified in this pass**: the exact default byte
  values of `$00`/`$01` after power-up (commonly cited elsewhere as
  `$2F`/`$37`) — the fetched c64-wiki page describes the *behavior*
  ("bits 0–2 configured as output by default, mode 31 selected") but
  doesn't state the full 8-bit values explicitly, so the guide avoids
  asserting them as sourced facts. Worth a follow-up if a later exercise
  needs the literal byte values.

## 3. KERNAL/BASIC-ROM references

- **Full 40-entry jump table with addresses and "real" ROM addresses**:
  parsed directly from `sta.c64.org/cbm64krnfunc.html`'s HTML table
  (old-style unclosed `<TR>`/`<TD>` markup, required splitting on `<TR`
  rather than a standard open/close-tag regex — noted here in case a
  future research pass hits the same page and wonders why a naive table
  parser returns zero rows). Function names, addresses, and one-line
  descriptions are all taken verbatim from that page; the guide condenses
  each entry's longer input/output/register description down to a short
  gloss for table-row brevity.
- **Structural comparison to Amiga LVOs/Atari `TRAP` calls**: this is an
  analytical framing choice (same "opcode understood, operand meaning
  external to the ISA" problem across all three retro platforms), not an
  independently sourced fact.
- **BASIC-ROM `SYS` bootstrap convention**: not independently re-sourced
  in this pass beyond the PRG-format research in §4 below (the `10 SYS
  2064`-style stub is standard, uncontested C64 knowledge, and the guide's
  claim is narrowly about *why* `$0801` is the common PRG load address,
  which §4's sources do cover).

## 4. PRG & cartridge (CRT) formats

- **PRG's 2-byte little-endian load-address header**: confirmed by two
  independent web sources during a `WebSearch` pass — c64-wiki.com's
  "LOAD" article and the Just Solve the File Format Problem wiki's
  "Commodore 64 binary executable" entry both describe the identical
  format (no third source fetched in full, since the two independently
  phrased descriptions already agreed and the format is trivially simple
  enough that a third check wasn't warranted).
- **`$0801` as the conventional load address, tied to the "free BASIC
  program storage" memory-map row and the `SYS`-stub bootstrap pattern**:
  cross-referenced against c64-wiki.com's "Memory Map" RAM-view table
  (already sourced in §2) rather than a separate fetch.
- **CRT header and CHIP-packet field tables**: read directly from the
  VICE Emulator Manual §17.14 ("17.14.1 Header contents," "17.14.2 CHIP
  Contents"), which documents its own worked example — a hex dump of a
  real 8K "Attack Of The Mutant Camels" cartridge. Every field value in
  the guide's two tables (header length `$40`, version `$0100`, hardware
  type `$0000`, `EXROM`/`GAME` = `$00`/`$01`, CHIP load address `$8000`,
  ROM size `$2000`) was **derived directly from that example's byte
  offsets**, cross-checked against the manual's own prose field
  descriptions where fetched (chip type, bank number, total-packet-length
  formula) and computed from the hex dump directly where the prose
  description wasn't captured in this pass's search snippets (load
  address and ROM-image-size *offsets* specifically — but the *values* at
  those offsets are read straight from the documented dump, and the
  arithmetic cross-checks: total packet length `$2010` = ROM size `$2000`
  + header `$10`, exactly matching the manual's stated formula). Treated
  as solid, not flagged Unresolved, given the internal consistency check.
- **No native Ghidra loader for PRG or CRT**: checked by listing every
  `*Loader.class` inside `Ghidra/Features/Base/lib/Base.jar` (29 classes,
  none C64/Commodore/PRG/cartridge-named) and by searching every `.jar` in
  the entire distribution for the substrings `c64`, `commodore`, `prg`,
  `cartridge` (only false-positive/unrelated hits: JNA native-library
  paths containing `ppc64`/`aix-ppc64`, a `CRC64` utility class, an Apache
  Velocity `EventCartridge` class). Also confirmed no `.opinion` file
  exists anywhere under `Ghidra/Processors/6502/` — unlike 68000, the
  6502 language isn't pre-wired to any loader at all in the shipped
  distribution.
- **Community options — `jamesham/ghidra-commodore` and
  `tom-seddon/Ghidra6502`**: found via `gh search repos` (queries
  `"ghidra c64"` — zero results, `"ghidra commodore"`, `"ghidra 6502"`).
  For `ghidra-commodore`: confirmed via `gh api` that it contains a real
  `CommodoreCartridgeLoader.java` (plus `CommodoreChipHeader.java`,
  `CommodoreCartridgeHeader.java` — matching the CRT field structure
  above), last commit 2022-01-03, **zero GitHub releases** (`gh api
  .../releases` returned an empty array), no PRG-loader class anywhere in
  its file tree. For `Ghidra6502`: confirmed via `gh api` last push
  2020-07-17, zero releases, its own README states the install method is
  "import the Eclipse project into your workspace, and run Ghidra from
  inside Eclipse" — i.e. no packaged/installable extension artifact at
  all. Both are flagged in the guide as real-but-uncertain rather than
  recommended outright, a stricter caveat than either the Amiga module
  gave `ghidra-amiga` (which at least has tagged, version-pinned releases)
  or the Atari module gave `czietz/ghidraScripts_for_Atari` (actively
  described as a no-build-step script collection).

## 5. VIC-II & SID registers

- **VIC-II full register table, `$D000`–`$D02E`**: transcribed directly
  from c64-wiki.com's "Page_208-211" article — a dedicated byte-level
  register table (80 rows in the raw parse, condensed to the guide's
  27-row summary by grouping the eight-fold sprite-coordinate and
  per-sprite-bitmask registers into single rows, since listing all eight
  `MxX`/`MxY`/`MxE`/etc. rows individually added length without adding
  distinct information).
- **SID register table, `$D400`–`$D418`**: transcribed directly from
  c64-wiki.com's "SID" article's own register table (47 raw rows,
  including sub-rows for individual bit fields within the pulse-width and
  control-register bytes — condensed into the guide's per-voice grid
  layout for readability, field meanings preserved verbatim).
- **VIC-II register mirroring up to `$D3FF`, and the C128-only `$D030`
  caveat**: the mirroring claim is standard/uncontested C64 hardware
  knowledge (the VIC-II only decodes its low address bits, so the 47
  "real" registers repeat across the full `$D000`-`$D3FF` window) and
  wasn't independently re-fetched in this pass; the `$D030` VIC-IIe caveat
  is included specifically to prevent a false generalization from a
  C128-oriented source, flagged here as a judgment call rather than a
  separately sourced fact.

---

## Unresolved / needs further verification

- **Exact power-up byte values of `$00`/`$01`** (commonly cited elsewhere
  as `$2F`/`$37`) — see §2. The *behavior* (bits 0–2 output, mode 31
  selected) is sourced; the specific full-byte values aren't, in this
  pass.
- **`ghidra-commodore`'s `CommodoreCartridgeLoader` internals** — confirmed
  to exist and to target the CRT format described in §4, but the actual
  Java source (how faithfully it implements the CHIP-packet parsing, bank
  handling, whether it builds Ghidra memory blocks matching this guide's
  table) wasn't reviewed beyond the file listing and `extension.properties`
  in this pass — same "defer until an exercises phase needs it" treatment
  the Amiga/Atari modules gave their own community-tool finds.
- **Live Ghidra verification in general**: as with every prior module, no
  local interactive Ghidra session was used to actually import a 6502
  binary and observe the Listing/default-symbol behavior firsthand in
  this pass — the `default_symbols`/`default_memory_blocks` claims in §1
  are read from the processor spec file directly (which Ghidra is
  documented to apply on import) rather than watched happening in the UI.
  Worth a sanity check against an installed 12.1.2 with a real 6502
  import once convenient.
- **6502 `imm8`/`imm16` token display formatting** (the `$`-hex-prefix
  claim in §1) — inferred from universal SLEIGH/Ghidra convention rather
  than read from the token's own `attach`/display definition in
  `6502.slaspec`, since that specific line wasn't isolated in this pass's
  grep. Low risk (this formatting is consistent across every published
  Ghidra 6502 disassembly this course's author has seen), but not the
  same standard of direct-source confirmation the rest of the addressing-
  mode table got.
