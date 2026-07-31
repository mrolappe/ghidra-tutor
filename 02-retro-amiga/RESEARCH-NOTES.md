# Research notes — 02-retro-amiga (Phase 5)

Two different kinds of sources feed this module, cited distinctly per fact:

- **Ghidra's own source**, checked against the same pinned tag used by
  00-quickstart and 01-core-workflows: `Ghidra_12.1.2_build`
  (`https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_12.1.2_build/<path>`
  where a bare path is given). Used for: how Ghidra's 68000 SLEIGH spec
  displays addressing modes/MOVEM/LINK/UNLK, the processor's declared
  endianness, and — critically — whether a native Amiga/Hunk loader exists
  in the shipped tree (checked by listing the `Loader` classes under
  `Ghidra/Features/Base/.../ghidra/app/util/opinion/` and by a full
  case-insensitive recursive search of the entire repo tree at this tag for
  `hunk`/`amiga`; see §2).
- **Amiga/68000 primary documentation**, none of it Ghidra-specific: the
  Motorola/Freescale/NXP **M68000 Family Programmer's Reference Manual**
  (`M68000PM.pdf`, order no. M68000PM/AD, downloaded from
  `cache.nxp.com/docs/en/reference-manual/M68000PM.pdf`), the **Amiga
  Hardware Reference Manual** (AHRM, Commodore/Addison-Wesley — Appendices B
  and D specifically, via the `amigadev.elowar.com`/`bastya.net` HTML mirror
  of the official AmigaOS Developer CD docs), the **Amiga ROM Kernel
  Reference Manual: Libraries and Devices** (RKM Libraries, chapter 17 and
  the LVO section, via the same mirror family plus `amiga.nvg.org`), the
  verbatim AmigaOS NDK header `dos/doshunks.h` (Copyright 1989–1999 Amiga,
  Inc.), and `amiga-dev.wikidot.com`'s Hunk file-format page (a
  well-established Amiga reverse-engineering reference wiki, cross-checked
  against `doshunks.h` for the numeric IDs rather than trusted alone). Copy
  protection material comes from Codetapper's site (a long-running,
  well-regarded Amiga preservation/cracking-history site) and the AmigaOS
  Documentation Wiki's CIA Resource page.

---

## 1. 68000 recap (for reading Ghidra disassembly, not a full ISA course)

- **Register set**: 8 general-purpose 32-bit data registers D0–D7, 8
  32-bit address registers A0–A7, a 32-bit Program Counter (PC), and an
  8-bit Condition Code Register (CCR) — the user-mode-visible low byte of
  the 16-bit Status Register (SR). **A7 is special**: "Register A7 is used
  as a hardware stack pointer during stacking for subroutine calls and
  exception handling. In the user programming model, A7 refers to the user
  stack pointer (USP)." In supervisor mode A7 instead refers to the
  interrupt/master stack pointer (ISP/MSP) — same register number, different
  physical register banked by privilege mode. Source: *M68000 Family
  Programmer's Reference Manual* (M68000PRM), §1.1 "Integer Unit User
  Programming Model" and §1.1.2 "Address Registers (A7–A0)", Figure 1-1.
- **CCR bits**, all 5, straight from the manual: **X** (Extend — set to the
  value of the carry bit for arithmetic ops, used for multi-precision
  arithmetic chains), **N** (Negative — set if the result's MSB is set),
  **Z** (Zero — set if the result is zero), **V** (Overflow — set if the
  result can't be represented in the operand size), **C** (Carry — set on
  carry-out of the MSB for addition, or borrow for subtraction). Source:
  M68000PRM §1.1.4 "Condition Code Register".
- **Big-endian — confirmed directly from Ghidra's own processor
  declaration**, not just general 68k knowledge: Ghidra's `68000.ldefs`
  declares every 68000-family language variant with `endian="big"` (e.g.
  `<language processor="68000" endian="big" size="32" variant="default" ...
  id="68000:BE:32:default">`). Practically: a 32-bit value like `$00 01 02
  03` in memory reads as `0x00010203`, the opposite of x86's little-endian
  byte order — a common trip-up switching from x86 RE work. Source:
  `Ghidra/Processors/68000/data/languages/68000.ldefs`.
- **Ghidra's default "68000" language ID actually loads the 68040
  instruction set** (a superset covering the base 68000 ISA plus later
  additions): the `variant="default"` entry in `68000.ldefs` uses
  `slafile="68040.sla"` and is described as "Motorola 32-bit 68040"; genuine
  68000/68010-only variants aren't separately listed (only `MC68020`,
  `MC68030`, `Coldfire` variants exist alongside `default`). In practice this
  is harmless for real 68000 binaries (they can't contain 68020+-only
  opcodes), but don't be surprised if Ghidra's own docs/labels say "68040"
  for what's actually plain-68000 Amiga code. Source: same `68000.ldefs`.
- **Addressing modes — official Motorola names/syntax vs. what Ghidra
  prints**. The full table (68020+; base 68000/68010 support a subset —
  Register Direct, Register Indirect incl. postincrement/predecrement/
  displacement, Address Register Indirect with Index (8-bit displacement
  only), Program Counter Indirect with (or without) Displacement/Index,
  Absolute Short/Long, Immediate; "Base Displacement", "Memory Indirect",
  and "PC Memory Indirect" rows are 68020+-only extensions and won't appear
  in real 68000-generation code):

  | Addressing mode | Motorola syntax |
  |---|---|
  | Register Direct (data / address) | `Dn` / `An` |
  | Register Indirect | `(An)` |
  | — with Postincrement | `(An)+` |
  | — with Predecrement | `–(An)` |
  | — with Displacement | `(d16,An)` |
  | Address Register Indirect with Index, 8-bit Displacement | `(d8,An,Xn)` |
  | Program Counter Indirect with Displacement | `(d16,PC)` |
  | Program Counter Indirect with Index | `(d8,PC,Xn)` |
  | Absolute Short / Long | `(xxx).W` / `(xxx).L` |
  | Immediate | `#<xxx>` |

  Source: M68000PRM Table 2-4, "Effective Addressing Modes and Categories"
  (§2.3), cross-referenced against §2.6.1 "System Stack" for the
  push/pop convention: "To implement stack growth from high memory to low
  memory, use `-(An)` to push data on the stack and `(An)+` to pull data
  from the stack." **Confirmed this is exactly what Ghidra's own 68000
  SLEIGH spec emits**: the `movemOp` constructor in Ghidra's shipped
  `68000.sinc` literally defines display strings `(regan)`, `(regan)+`,
  `-(regan)`, `(d16, regan)`, `(d16,PC)` — the identical syntax family (down
  to the same punctuation), just with a Ghidra-internal register-token name
  substituted for `An`. Source:
  `Ghidra/Processors/68000/data/languages/68000.sinc` (`movemOp:` table,
  ~line 2681 onward).
- **MOVEM (register list save/restore)**: confirmed in Ghidra's shipped
  SLEIGH source — `movem.w`/`movem.l` support both directions (registers→
  memory and memory→registers), and predecrement-mode MOVEM writes the
  *updated* address back into the address register afterward (`movemWrt:`
  construct: `is (mode=3 | mode=4) & regan { regan = movemptr; }`). One
  practical surprise for reading Ghidra's Listing: **the register list is
  rendered as individual space-separated register names** (e.g. built up
  token-by-token as `"D0" " " "D1" " " "D2"...`), not compressed into
  ranges like `D2-D7/A2-A6` the way some other disassemblers show it.
  Source: `Ghidra/Processors/68000/data/languages/68000.sinc`, register-list
  tables `r2mfwf`/`r2mfwe`/... and the `:movem.w`/`:movem.l` constructors
  (~lines 1702–1950).
- **LINK / UNLK (stack frame setup/teardown)** — exact semantics from
  Ghidra's own SLEIGH definitions: `LINK An,#d16` does `SP=SP-4; *SP=An;
  An=SP; SP=SP+d16` (push the frame pointer, make it the new frame pointer,
  then reserve `d16` bytes of locals — `d16` is usually negative on real
  code, since SP grows downward). `UNLK An` reverses it: `SP=An; An=*SP;
  SP=SP+4` (restore SP to the frame pointer, pop the saved frame pointer
  back into `An`). Source:
  `Ghidra/Processors/68000/data/languages/68000.sinc` lines 1583–1584
  (`:link.w`, `:link.l`) and 2307 (`:unlk`).
- **TRAP #n and the exception vector table**: `TRAP #<n>` (n = 0–15) causes
  a trap through **vectors 32–47** ("TRAP #0–15 Instruction Vectors" in the
  table, vector offsets `$080`–`$0BC`) — i.e. each `TRAP #n` jumps through
  its own fixed vector-table slot, commonly used by OSes as a syscall gate
  (not the mechanism AmigaOS itself uses for library calls — see §3 — but
  common on other 68k systems and worth recognizing). Source: M68000PRM
  Table B-1, "Exception Vector Assignments for the M68000 Family". Same
  table also directly confirms the two "unimplemented opcode" traps worth
  recognizing when disassembly hits a reserved opcode pattern: **vector 10,
  offset `$028`, "Line 1010 Emulator (Unimplemented A-Line Opcode)"** and
  **vector 11, offset `$02C`, "Line 1111 Emulator (Unimplemented F-Line
  Opcode)"** — any instruction word whose top 4 bits are `1010` or `1111`
  and isn't a real opcode on the given CPU model traps through one of
  these two vectors (this is the general 68k mechanism some platforms use
  to trap into OS-provided emulation/dispatch code for opcodes the base CPU
  doesn't implement).

## 2. Amiga Hunk executable format

- **Hunk type IDs — from the actual AmigaOS NDK header**, not a
  paraphrase: `Includes/dos/doshunks.h` (Release 2.04 Includes, V37.4,
  "(C) Copyright 1989-1999 Amiga, Inc.") defines: `HUNK_UNIT 999`,
  `HUNK_NAME 1000`, `HUNK_CODE 1001`, `HUNK_DATA 1002`, `HUNK_BSS 1003`,
  `HUNK_RELOC32 1004`, `HUNK_RELOC16 1005`, `HUNK_RELOC8 1006`,
  `HUNK_EXT 1007`, `HUNK_SYMBOL 1008`, `HUNK_DEBUG 1009`, `HUNK_END 1010`,
  `HUNK_HEADER 1011`, `HUNK_OVERLAY 1013`, `HUNK_BREAK 1014`,
  `HUNK_DREL32 1015`, `HUNK_DREL16 1016`, `HUNK_DREL8 1017`, `HUNK_LIB
  1018`, `HUNK_INDEX 1019` (note: no `1012` — not a gap in transcription,
  it's simply unused/reserved between HEADER and OVERLAY). Source:
  `amigadev.elowar.com/read/ADCD_2.1/Includes_and_Autodocs_2._guide/node0065.html`
  (mirror of the literal NDK header file text).
- **Only the low 29 bits of a hunk ID are the type** (except the very
  first `HUNK_HEADER`): the top bits of a hunk-size longword in
  `HUNK_HEADER` double as `AllocMem()` memory-attribute flags (bit 31 = must
  be Fast RAM, bit 30 = must be Chip RAM, both set = an extra flags
  longword follows, bit 30 cleared in it before use). Every hunk memory
  block is implicitly allocated `MEMF_PUBLIC`. Source:
  `amiga-dev.wikidot.com/file-format:hunk`, "HUNK_HEADER [0x3F3]" section
  (cross-checked: `0x3F3` = decimal 1011 = `HUNK_HEADER`, matching
  `doshunks.h`).
- **Block layouts** (all confirmed structurally against `doshunks.h`'s
  numeric IDs):
  - `HUNK_HEADER` — optional resident-library-name string list (expected
    empty for load files, or the loader fails with `ERROR_BAD_HUNK`), a
    hunk-count table size, first/last hunk-table indices, then one size
    longword (with the memory-flag bits above) per hunk.
  - `HUNK_CODE` / `HUNK_DATA` — a longword count *N* (number of longwords),
    followed by *N* longwords of raw machine code / initialized data.
  - `HUNK_BSS` — just a longword count of zeroed longwords to allocate; not
    followed by relocation data since there's nothing to relocate against
    within it.
  - `HUNK_RELOC32` — repeating groups of `{count, target-hunk-number,
    count × offset}` longwords, terminated by a zero count; each listed
    offset in the *current* hunk gets the target hunk's load address added
    to whatever longword is already stored there.
  - `HUNK_SYMBOL` — repeating `{name-string, offset}` pairs, terminated by
    a zero-length name.
  - `HUNK_END` — a bare marker with no payload, closing out the current
    hunk.
  - Source for all of the above:  `amiga-dev.wikidot.com/file-format:hunk`
    (per-block sections, each showing the exact field layout and a
    reference reader implementation).
- **Ghidra does NOT ship a native Amiga/Hunk loader.** Verified two ways
  against the pinned `Ghidra_12.1.2_build` tag: (1) the `Loader`
  implementations under
  `Ghidra/Features/Base/src/main/java/ghidra/app/util/opinion/` list
  `ElfLoader`, `PeLoader`, `MachoLoader`, `CoffLoader`, `MSCoffLoader`,
  `PefLoader`, `MzLoader`, `NeLoader`, `DbgLoader`, `Omf51Loader`,
  `OmfLoader`, `SomLoader`, `UnixAoutLoader`, `IntelHexLoader`,
  `MotorolaHexLoader`, `DyldCacheLoader`, `GdtLoader`, `GzfLoader`,
  `BinaryLoader`, `XmlLoader`/`DecompileDebugXmlLoader`, `DefLoader`,
  `MapLoader` — no Hunk-related class anywhere in the list. (2) A full
  case-insensitive recursive search of every file path in the entire
  `Ghidra_12.1.2_build` repo tree for `hunk` or `amiga` turns up **zero**
  real hits (the only `hunk`-adjacent matches are unrelated `Thunk*`
  substrings — thunk functions, PE thunk data, PDB thunk symbols — nothing
  Amiga-specific at all). Consistent with this, `68000.opinion` (the file
  that tells Ghidra's importer which loader/container formats pair with
  the 68000 processor) only wires the 68000 language to the ELF, PEF, Palm
  Pilot Program, and a-out loaders — no Hunk entry. Sources:
  `Ghidra/Features/Base/src/main/java/ghidra/app/util/opinion/` (directory
  listing via GitHub API), `Ghidra/Processors/68000/data/languages/68000.opinion`,
  and a recursive `git/trees` search at the same tag.
- **Practical consequence / community option**: to actually load a Hunk
  executable in Ghidra, a third-party extension is needed. The best-known
  one is `BartmanAbyss/ghidra-amiga` on GitHub ("Ghidra Amiga Extension.
  Load Amiga Hunk executables, Kickstart ROMs and WinUAE state files
  (.uss). Includes NDK 3.9 symbols" — itself built on an earlier
  `lab313ru/ghidra_amiga_ldr`). This is a community project, not reviewed
  in depth for this research pass beyond its own README description — see
  Unresolved.

## 3. exec.library / Kickstart basics

- **What exec.library is**: "The Multitasking Executive, better known as
  Exec, is the heart of the Amiga's operating system. All other systems in
  the Amiga rely on it to control multitasking, to manage the message-based
  interprocess communications system, and to arbitrate access to system
  resources." Source: *Amiga ROM Kernel Reference Manual: Libraries*
  ("RKM Libraries"), Chapter 17, "Introduction to Exec" (mirror:
  `theflatnet.de/pub/cbm/amiga/AmigaDevDocs/lib_17.html`).
- **The one fixed, absolute memory address on the whole system**: "the
  first step is to fetch the address of the exec.library from location 4;
  this is the only absolute memory location in the system. All other
  system data structures are indirectly linked to this base address."
  (i.e. the long-word at address `$4` always holds the running system's
  `ExecBase`/`SysBase` pointer — everything else, including where Kickstart
  itself sits, is soft/relocatable). Source: AHRM Appendix D, "System
  Memory Maps" (mirror: `bastya.net/AmigaDevDocs/hard_d.html`).
- **Library Vector Offsets (LVOs) — negative-offset jump table below the
  library base**: "Each function's entry in the jump table ... is always a
  constant (negative) offset from the library base ... An application
  enters a library function by doing a jump to subroutine (JSR) to the
  proper negative offset (LVO) from the address of the library base. The
  library vector itself is a jump instruction (JMP) to the actual library
  function." The first four vectors of *every* library are reserved for
  housekeeping, always at the same offsets: `OPEN` = LVO `-6`, `CLOSE` =
  `-12`, `EXPUNGE` = `-18`, `RESERVED` = `-24`; user-callable functions
  continue from LVO `-30` (function 5) upward in steps of 6 bytes (one JMP
  instruction per vector: `LVO = -(N*6)`). "A function's LVO is always the
  same on every system and is not subject to change" (unlike the jump
  vector's target, which can). Source: *Amiga ROM Kernel Reference Manual:
  Libraries*, Chapter 17, "Library Vector Offsets (LVOs)" section (mirror:
  `amiga.nvg.org/amiga/reference/Libraries_Manual_guide/node028F.html`),
  Figure 17-1 exactly reproducing the low-memory-jump-table-below-base
  layout.
- **Concrete example — `OpenLibrary`**: widely and consistently documented
  (across several independent developer references, not one single primary
  document fetched in this pass — see Unresolved) as **LVO `-552`** off
  `exec.library`'s base, called as `JSR -552(A6)` after loading `A6` with
  `SysBase` (long-word at address `4`), the library name pointer in `A1`,
  and the minimum acceptable version in `D0`. Symbolically written
  `JSR _LVOOpenLibrary(A6)` once the offset is given a named constant
  (which is exactly what the NDK's `.fd`/pragma files exist to do —
  generate named LVO constants instead of writing raw negative numbers).
- **Why this shows up as an unnamed `jsr -552(a6)` in Ghidra without
  FD/NDK data loaded**: structurally, `-552(A6)` is nothing more than
  ordinary 68000 **Address Register Indirect with Displacement**
  addressing (`(d16,An)` from §1's addressing-mode table) used as a call
  target — Ghidra has no built-in knowledge that `A6` conventionally holds
  a library base at this point, or that negative displacements off a
  library base are a jump table, so it just disassembles the literal
  operand: register `A6`, displacement `-552`, no symbol, because nothing
  in a plain binary import ties that address to a name. (Loading Amiga NDK
  `.fd`-derived data type/symbol info — planned for a later exercise/tool
  step — is what lets a decompiler-aware workflow resolve `-552(A6)` to
  `_LVOOpenLibrary` instead.)
- **Kickstart ROM location in the memory map** — directly from AHRM
  Appendix D's per-model address tables:
  - A1000 / A500 / A2000: `$FC0000`–`$FFFFFF`, "256K System ROM".
  - A3000-class systems: `$00F80000`–`$00FFFFFF`, "High ROM (512K)" (the
    512KB Kickstart image; A3000 also reserves `$00F00000`–`$00F7FFFF` for
    a separate, disabled-by-default "Diagnostic ROM").
  - Custom chip registers sit at `$DFF000`–`$DFFFFF` on the A1000/A500/A2000
    map (labeled "Chip registers. See Appendix A and Appendix B") — see §4.
  Source: AHRM Appendix D, "A1000, A500 and A2000 Memory Map" and "A3000
  Memory Map" tables (mirror: `bastya.net/AmigaDevDocs/hard_d.html`).

## 4. Custom chip registers (Agnus / Denise / Paula)

- **Base address `$DFF000`**, confirmed directly in the AHRM's own memory
  map (§3 above: "`DF F000 - DF FFFF` Chip registers. See Appendix A and
  Appendix B"). All register offsets below are added to this base.
- **Chip-ownership notation**: the AHRM's own Appendix B legend states "A,D,P
  A=Agnus chip, D=Denise chip, P=Paula chip" (a register can be jointly
  owned, e.g. `ADP`, `AD`); the appendix also flags ECS
  (Enhanced Chip Set, found in the A3000 and installable in the A500/A2000)
  additions with `(E)`. Source: AHRM, "Appendix B: Register Summary,
  Address Order" (mirror:
  `bastya.net/AmigaDevDocs/hard_b.html`), legend + register table (verbatim
  text, not a third-party retyping).
- **Representative register sample** (offset from `$DFF000`, R/W, owning
  chip, function — all verbatim from the same Appendix B table):

  | Register | Offset | R/W | Chip | Function |
  |---|---|---|---|---|
  | `DMACONR` | `$002` | R | A, P | DMA control (and blitter status) read |
  | `DMACON` | `$096` | W | A, D, P | DMA control write (clear or set) |
  | `INTENAR` | `$01C` | R | P | Interrupt enable bits read |
  | `INTENA` | `$09A` | W | P | Interrupt enable bits (clear or set) |
  | `INTREQR` | `$01E` | R | P | Interrupt request bits read |
  | `INTREQ` | `$09C` | W | P | Interrupt request bits (clear or set) |
  | `COP1LCH` | `$080` | W | A (E) | Copper first location register, high 3 (5 on ECS) bits |
  | `COP1LCL` | `$082` | W | A | Copper first location register, low 15 bits |
  | `COP2LCH` / `COP2LCL` | `$084` / `$086` | W | A (E) / A | Copper second location register |
  | `COPJMP1` / `COPJMP2` | `$088` / `$08A` | S (strobe) | A | Restart Copper at first/second location |
  | `BLTCON0` / `BLTCON1` | `$040` / `$042` | W | A / A (E) | Blitter control registers 0/1 |
  | `BPLCON0` | `$100` | W | A, D (E) | Bitplane control register (misc. display control bits) |
  | `DIWSTRT` / `DIWSTOP` | `$08E` / `$090` | W | A | Display window start/stop position |
  | `AUD0LCH` / `AUD0LCL` | `$0A0` / `$0A2` | W | A (E) / A | Audio channel 0 sample pointer |
  | `AUD0LEN` | `$0A4` | W | P | Audio channel 0 length |
  | `AUD0PER` | `$0A6` | W | P (E) | Audio channel 0 period |
  | `AUD0VOL` | `$0A8` | W | P | Audio channel 0 volume |
  | `AUD0DAT` | `$0AA` | W | P | Audio channel 0 data (to Paula's DAC) |

  Source: same AHRM Appendix B table (verbatim offsets/labels, mirror as
  above).
- **Read/write asymmetry is common and worth flagging for RE**: several
  registers have *separate* addresses for reading vs. writing the same
  logical state — e.g. `DMACON` (write, `$096`) vs. `DMACONR` (read,
  `$002`), and likewise `INTENA`/`INTENAR`, `INTREQ`/`INTREQR` — so seeing
  code read and write "the same register name" at two different offsets
  from `$DFF000` in a disassembly is expected, not a bug in the analysis.
  Source: same Appendix B table.

## 5. Typical Amiga copy-protection patterns (RE-recognition, not a how-to)

- **Non-standard track formats read-but-not-write**: from an interview
  with Rob Northen (creator of the widely-licensed "Copylock" protection,
  used across Amiga/Atari ST/PC titles) on a long-running Amiga
  preservation site: "The method used on the floppy to create a Copylock
  track was to use a format that the Amiga drive could read without error,
  but was unable to write." This "normally involved changing the bitcell
  size of outputted bytes written to the track" for one specific sector —
  producing a track a standard disk-copy program reproduces incorrectly
  even though the original drive reads it fine. Source: "An interview with
  Rob Northen", `codetapper.com/amiga/interviews/rob-northen/`.
- **Timing-based sector detection**: "Using a carefully written piece of
  code I was able to detect this special sector by comparing the times to
  read in both types of sector. From memory, I think the 'slow' sector had
  to take at least 15% longer to read than the other sectors or it failed
  the protection test." This kind of timing check is a natural fit for the
  Amiga's CIA (8520) chip timers — the AmigaOS documentation describes the
  CIA resource as providing "two interval timers ... Timer A and Timer B"
  per CIA chip, intended for "high performance timing applications" (the
  same primitive protection code repurposes for measuring disk-read
  duration rather than the documented MIDI/SMPTE use cases). Sources:
  Codetapper Rob Northen interview (as above); AmigaOS Documentation Wiki,
  "CIA Resource" (`wiki.amigaos.net/wiki/CIA_Resource`).
- **Keydisk / embedded-serial-number schemes**: rather than a single
  hard-coded pass/fail check, Northen's scheme issued each licensee
  "a different set of keydisks that would have a unique serial number.
  When my code was called it would either return 0 if the protection
  failed or a 32-bit serial number of the keydisk" — and explicitly advised
  developers not to just compare the result against a constant, but to
  "incorporate somehow the number into their own data, which would be used
  later in the game" (i.e. mix the check's result into a game-logic value
  rather than branching on it, to defeat simple patch-the-branch cracking).
  Source: same Codetapper interview.
- **Anti-disassembly obfuscation around the check itself**: the same
  source describes self-modifying code and XOR-based obfuscation
  specifically to complicate reverse engineering of the serial-number
  validation routine — i.e. the protection code doesn't just check once,
  it also actively resists being read statically. Source: same Codetapper
  interview.
  For recognizing this in Ghidra: expect functions whose bytes visibly
  change at runtime (writes to addresses inside the current code hunk),
  and/or checksum loops over a code or data hunk compared against a
  constant — either is a strong signal of a protection or anti-tamper
  routine rather than ordinary program logic.
- **"Trap-door" bootstrap loaders replacing the OS boot path**: floppy
  boot blocks can contain custom code that runs *before* AmigaDOS/Kickstart
  hands off to the normal filesystem loader, letting a protected disk run
  its own bespoke loader (check the special track, then load and decrypt
  the real program) instead of a standard Hunk-format load — this is the
  generic mechanism a "trap door" custom loader relies on. The commonly
  repeated technical elaboration of Copylock specifically — that it used
  the 68000's trace-exception mode to decrypt only one or two instructions
  of the real program into memory at a time, so the plaintext code was
  never fully resident — comes from Wikipedia's "Rob Northen copylock"
  article, which **by its own editorial tags relies on a single source and
  flags possible original-research concerns**; treated here as a plausible,
  widely-repeated description worth knowing about, not as an
  independently-confirmed primary-source fact. Source (caveated as above):
  `en.wikipedia.org/wiki/Rob_Northen_copylock`.

---

## Unresolved / needs further verification

- **`OpenLibrary`'s LVO of `-552`**: consistently repeated across several
  independent developer references (a blog on Amiga library mechanics, a
  wiki tutorial, forum-style write-ups) and internally consistent with the
  documented `-(N*6)` LVO formula (552 = 6 × 92, i.e. `OpenLibrary` is
  jump-table function #92 counting from the 4 reserved housekeeping
  vectors), but this pass did not manage to fetch the actual NDK
  `fd/exec_lib.fd` or a generated `pragmas/exec_pragmas.h` file — the true
  machine-readable primary source for the number — directly (network
  fetches to a couple of likely mirrors failed in this environment). Worth
  double-checking against a real Amiga NDK/AROS `exec_lib.fd` if one
  becomes available.
- **`amiga-dev.wikidot.com`'s own citations**: the Hunk-format page lists a
  "References"/"External Links" section, but the fetched/stripped HTML
  didn't preserve the link text, so it wasn't possible to confirm in this
  pass exactly which upstream document(s) *that page* cites beyond what
  was independently cross-checked here against the literal `doshunks.h`
  NDK header (which does fully confirm every numeric hunk-type ID used).
- **`BartmanAbyss/ghidra-amiga` (community Ghidra Amiga extension)
  internals**: confirmed to exist, confirmed by its own README to load
  Hunk executables/Kickstart ROMs/WinUAE state files and ship NDK 3.9
  symbols, but this pass did not review its actual source to confirm
  specifics like exact loader class name(s), whether `HUNK_RELOC32`
  relocations are fully resolved at import time, or whether each hunk
  becomes its own named Ghidra memory block. Worth a closer look once a
  later phase actually needs to recommend/use it (e.g. an exercises phase
  that has learners import a real Hunk binary).
- **Amiga Hardware Reference Manual edition/printing used**: the mirrors
  cited (`amigadev.elowar.com`/`bastya.net` HTML, plus the archive.org OCR
  text of the 1985 first edition also spot-checked during research) are
  reproductions of Commodore/Addison-Wesley's official AHRM, but this pass
  didn't pin down which exact edition/printing every mirrored page
  corresponds to (the AHRM went through multiple editions as ECS/AGA
  chipsets were added) — the register table cited in §4 explicitly
  self-identifies ECS-added/changed registers with `(E)`, which is the
  detail that actually matters for RE purposes, so this is a low-risk gap.
- **Live Ghidra verification in general**: as with prior modules, no local
  Ghidra install was available for this research pass. Everything about
  how Ghidra *displays* 68000 disassembly (addressing-mode syntax,
  register-list rendering, etc.) is derived from reading the shipped
  SLEIGH source directly, not from observing the Listing window on a real
  import — worth a sanity check against an installed 12.1.2 with an actual
  68000 binary once convenient.

---

## Phase 6 addendum — exercises research

- **`ghidra-amiga` release/version status** (resolves the open item from
  Phase 5 §"Unresolved"): checked via `gh api
  repos/BartmanAbyss/ghidra-amiga/releases` — the project is actively
  maintained (latest release tag `20260128`, ~6 months old as of this
  phase), but each release build targets one specific Ghidra point release
  (`20260128`'s only asset is
  `ghidra_12.0.1_PUBLIC_20260128_ghidra-amiga.zip` — built for 12.0.1, not
  this course's pinned 12.1.2). Internals (loader class, relocation
  handling, one-block-per-hunk-or-not) are still unverified, as noted in
  Phase 5. Exercise 03 documents this version gap directly rather than
  assuming the prebuilt zip is a drop-in match.
- **`DMACON`/`INTENA` "SET/CLR" write convention** (bit 15 of the written
  word selects set-vs-clear for whichever other bits are `1`; `DMAEN` is
  bit 9 of `DMACON`, not bit 13 as an earlier draft of the sample
  incorrectly assumed): confirmed via the Amiga Hardware Reference
  Manual's DMA Control chapter, `amigadev.elowar.com/read/ADCD_2.1/
  Hardware_Manual_guide/node0170.html` ("7 System Control Hardware / DMA
  Control") and the DMACON/DMACONR register-summary page at
  `amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node002F.html`.
  Not previously verified in Phase 5 (that guide only tabulated register
  names/offsets/chip ownership, not individual bit meanings) — worth
  folding a short "SET/CLR convention" note into
  `04-custom-chip-registers.md` itself if a future pass revisits that
  guide.
