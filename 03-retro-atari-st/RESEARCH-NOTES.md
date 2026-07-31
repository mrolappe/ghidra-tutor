# Research notes — 03-retro-atari-st (Phase 7)

Three kinds of sources feed this module, cited distinctly per fact:

- **Ghidra's own source**, checked against the same pinned tag used by every
  prior module: `Ghidra_12.1.2_build`
  (`https://github.com/NationalSecurityAgency/ghidra/blob/Ghidra_12.1.2_build/<path>`
  where a bare path is given). Used for: the 68000 processor's declared
  endianness (same file the Amiga module already cited, re-confirmed fresh
  for this module rather than assumed) and — critically — whether a native
  PRG/TOS/GEMDOS loader exists in the shipped tree, checked the same way the
  Amiga module checked for a Hunk loader: listing every `Loader` class under
  `Ghidra/Features/Base/.../ghidra/app/util/opinion/`, and a full
  case-insensitive recursive search of every path in the entire repo tree at
  this tag for `atari`, `gemdos`, and `prg`.
- **The Atari Compendium** (©1992 Software Development Systems, written by
  Scott Sanders) — the closest Atari-world equivalent to the Amiga module's
  RKM/AHRM: a from-Atari's-own-developer-documentation reference covering
  GEMDOS, BIOS, XBIOS, the PRG header, and the basepage. Its own
  introduction states its five source categories: "Atari Developer
  Documentation, including, but not limited to, original OS docs, release
  notes, newsletters, and technical support," Compute!'s AES/TOS/VDI book
  series, the Lattice C Atari Library Manual, the German-language "Atari
  Profibuch," and Atari developer-roundtable transcripts — i.e. compiled
  from Atari's own published developer material, not from disassembling a
  ROM. Fetched as PDF from `info-coach.fr/atari/software/_development/
  Atari-Compendium.pdf` (a long-standing, widely-mirrored copy — the same
  content is also mirrored at `cd.textfiles.com/ataricompendium/`,
  `bus-error.nokturnal.pl/atari_compendium/`, and served as hypertext at
  `tho-otto.de/hypview/hypview.cgi?url=/hyp/compend.hyp`), converted locally
  with `pdftotext -layout` for exact-text search since the PDF didn't
  extract cleanly through automated web-fetch summarization. All Compendium
  quotes below cite section titles/page numbers as printed in the document
  itself (e.g. "2.103" = Book 2, page 103) since the mirrors don't share a
  single stable URL scheme with section anchors.
- **FreeMiNT project's `tos.hyp`** (`freemint.github.io/tos.hyp`) — an
  actively-maintained, openly-hosted continuation/restatement of the same
  TOS API documentation, used here as an independent cross-check on at
  least one of the three TRAP numbers (BIOS) rather than relying on the
  Compendium alone, plus as evidence of a legally cleaner citable source
  than a "not for public distribution"-marked 1992 draft (see §5).
  Community/practitioner sources — `czietz/ghidraScripts_for_Atari` on
  GitHub (Ghidra-import helper scripts for Atari binaries) and Atari-Forum
  discussion threads — are used only where flagged as such, for the
  "no native Ghidra loader → community workaround" story and for the
  user/supervisor-mode nuance that the Compendium's spec text alone doesn't
  fully settle (see §1 and Unresolved).

---

## 1. 68000/TOS differences from Amiga

This module explicitly does **not** repeat `02-retro-amiga/01-68000-recap.md`
(register set, CCR bits, addressing modes, MOVEM/LINK/UNLK semantics,
TRAP-vector mechanics in general — all CPU-level facts that hold on any
68000 platform). What follows is only what actually differs for Atari
ST/TOS.

- **Endianness — no surprise, re-confirmed independently for this module**:
  Ghidra's `68000.ldefs` declares the processor `endian="big"` regardless
  of platform (`<language processor="68000" endian="big" size="32"
  variant="default" ... id="68000:BE:32:default">`, description "Motorola
  32-bit 68040" — the same "default variant actually loads the 68040 SLA"
  quirk the Amiga module already documented, and it's identical here since
  it's the same file/declaration, not a per-platform setting). Atari ST/STE
  used the plain MC68000; later TT/Falcon models moved to the 68030/68040 —
  all still big-endian per the M68000 family architecture. There is no
  endianness difference between Amiga and Atari ST code; both are compiled
  for the same big-endian 68000 ISA. Source:
  `Ghidra/Processors/68000/data/languages/68000.ldefs` (fetched at
  `Ghidra_12.1.2_build`).
- **The Atari analogue of "SysBase at address 4" is the *basepage*, but the
  mechanism is different in kind, not just in name.** AmigaOS's `ExecBase`
  is a single well-known **absolute address** (`$4`) that every running
  program reads to find the *system*. TOS instead hands each *individual
  process* a pointer to **its own private basepage** at process-start time,
  passed as **a stack argument**, not a fixed memory address: "GEMDOS
  executable files ... JMP's to the first byte of the application's TEXT
  segment with the address of your process's basepage at 4(sp)." The
  Compendium's own reference startup code confirms exactly how this is
  read: `move.l 4(sp),a0 ; Obtain pointer to basepage`. There is no
  Atari equivalent of "read a fixed address to find the OS" — each program
  gets its *own* basepage pointer freshly on the stack, and the *system*
  itself is instead reached indirectly (via GEMDOS/BIOS/XBIOS TRAP calls,
  see §2), not via a shared fixed-address global structure. Source: The
  Atari Compendium, "GEMDOS Processes" (Book 2, pp. 2.9–2.11), the exact
  quoted sentence and the `_start:` example code block.
- **Basepage structure — full field table, all offsets** (analogous in
  *role* to Amiga's `ExecBase`-plus-hunk-table combined, but laid out as a
  flat 256-byte struct at a process-specific address rather than a fixed
  location):

  | Field | Offset | Size | Meaning |
  |---|---|---|---|
  | `p_lowtpa` | `0x00` | LONG | pointer to base of the Transient Program Area (TPA) |
  | `p_hitpa` | `0x04` | LONG | pointer to top of the TPA + 1 |
  | `p_tbase` | `0x08` | LONG | pointer to base of the TEXT segment |
  | `p_tlen` | `0x0C` | LONG | length of the TEXT segment |
  | `p_dbase` | `0x10` | LONG | pointer to base of the DATA segment |
  | `p_dlen` | `0x14` | LONG | length of the DATA segment |
  | `p_bbase` | `0x18` | LONG | pointer to base of the BSS segment |
  | `p_blen` | `0x1C` | LONG | length of the BSS segment |
  | `p_dta` | `0x20` | LONG | pointer to the process's DTA (Disk Transfer Address) |
  | `p_parent` | `0x24` | LONG | pointer to parent process's basepage |
  | `p_reserved` | `0x28` | LONG | unused/reserved |
  | `p_env` | `0x2C` | LONG | pointer to the process's environment string |
  | `p_undef` | `0x30` | 80 bytes | unused/reserved |
  | `p_cmdlin` | `0x80` | 128 bytes | copy of the command-line image |

  (`0x80 + 128 = 0x100` = 256 bytes total — a fixed-size struct, unlike
  Amiga's variable-length hunk table.) Source: The Atari Compendium,
  "GEMDOS Processes" (Book 2, pp. 2.11–2.12), "The GEMDOS BASEPAGE
  structure has the following members" table, verbatim field names/offsets.
- **Stack/register convention at program entry**: on entry, `A7`/`SP`
  points at the return-address slot GEMDOS pushed, and `4(sp)` (i.e. right
  after that return address) holds the basepage pointer — confirmed by the
  Compendium's own canonical startup boilerplate (`move.l 4(sp),a0`). A
  well-behaved program is then expected to compute how much memory it
  actually needs (TPA size = new stack top − basepage address) and call
  `Mshrink()` (GEMDOS opcode `0x4A`, via `TRAP #1`) to release the rest
  back to the system — the Compendium spells this out as "the proper way to
  release system memory and allocate your stack (most 'C' startup routines
  do this for you)," with the full example code. This has no Amiga
  parallel: exec.library doesn't hand a fresh process a whole-remaining-RAM
  block that it's expected to voluntarily shrink. Source: same "GEMDOS
  Processes" section, `_start:`/`stacksize` code listing.
- **Whether TOS also banks A7 into user/supervisor like Amiga's exec
  does — this is more nuanced than the Amiga case and is only partly
  settled by a primary source; see also Unresolved.** The USP/SSP banking
  itself is generic 68000 CPU hardware (M68000PRM, already cited in the
  Amiga module — not platform-specific). What differs is *which mode TOS
  programs actually run in*. The Compendium's own XBIOS chapter states, as
  a normative/spec claim: **"Normal programs always execute in user mode.
  Programs operating in user mode, however, have less memory access
  privileges than those operating in supervisor mode... any memory reads or
  writes to locations $0–$7FF or memory-mapped I/O must be made in
  supervisor mode"** — and documents `Super()` (GEMDOS opcode `0x20`, via
  `TRAP #1`) as the mechanism a program uses to explicitly request
  supervisor mode (`SUP_SET`/`stack=0`) or drop back to user mode, saving/
  restoring the old SSP as the call's return value. This is a real,
  documented API — not invented for this course. **However**, this pass
  could not confirm from a primary source whether classic single-tasking
  TOS's `Pexec()` actually *puts the CPU in user mode* before jumping to a
  freshly loaded program, or whether it simply leaves the CPU in whatever
  mode it already was in (commonly supervisor, inherited from the TRAP #1
  handler context) and trusts well-behaved programs to call `Super()`
  themselves if they want the stricter mode — several Atari-Forum threads
  and community write-ups describe the latter as the practical historical
  reality (most ST games/demos never call `Super()` at all and freely poke
  hardware registers directly), but no primary Atari document fetched in
  this pass states the *default entry-mode* explicitly. Flagged in
  Unresolved. **Practical takeaway for the guide regardless of which is
  true**: unlike the Amiga notes (where A7 banking was cited purely as
  general CPU background, not something to look for as a program-flow
  signal), on Atari ST a reverse engineer *should* watch for `Super()`
  calls (`move.w #$20,-(sp)` / `trap #1` pattern) and treat them as a
  genuine "this code is about to touch hardware directly" marker — a
  recognizable pattern that has no real Amiga-side equivalent, since
  AmigaOS code doesn't privilege-gate custom-chip access at all (see the
  Amiga module's §4 — custom chip registers there are just plain memory-
  mapped, no mode switch needed). Source: The Atari Compendium, "User/
  Supervisor Mode" (Book 4, p. 4.11) and the `Super()` function reference
  (Book 2, p. 2.128–2.129).

## 2. GEMDOS/BIOS/XBIOS call recognition

- **TRAP numbers — verified against the primary reference, not accepted on
  the strength of the common claim alone**, and cross-checked two
  independent ways:
  1. Explicit statements in the Compendium's own "Function Calling
     Procedure" section for each API:
     - "**GEMDOS system functions are called via the TRAP #1 exception.**
       Function arguments are pushed onto the current stack in reverse
       order followed by the function opcode." (Book 2, p. 2.9,
       "GEMDOS Function Calling Procedure")
     - "**BIOS system functions are called via the TRAP #13 exception.**
       Function arguments are pushed onto the current stack (user or
       supervisor) in reverse order followed by the function opcode."
       (Book 3, p. 3.21, "BIOS Function Calling Procedure")
     - "**XBIOS system functions are called via the TRAP #14 exception.**
       Function arguments are pushed onto the current stack (user or
       supervisor) in reverse order followed by the function opcode."
       (Book 4, p. 4.19, "XBIOS Function Calling Procedure")
  2. The Compendium's own hardware/vector-table appendix independently
     lists the same three vectors by name: `VEC_GEMDOS` = `0x21` = "Trap #1
     (GEMDOS)", `VEC_BIOS` = `0x2D` = "Trap #13 (BIOS)", `VEC_XBIOS` =
     `0x2E` = "Trap #14 (XBIOS)" — and elsewhere in the same appendix, the
     concrete memory-map addresses of the installed handlers: `$84` (TRAP
     #1 handler), `$B4` (TRAP #13 handler), `$B8` (TRAP #14 handler),
     which is arithmetically consistent with standard 68000 vector-table
     layout (vector N lives at offset N×4; vector 33 → `0x84`, vector 45 →
     `0xB4`, vector 46 → `0xB8` — matching TRAP #1/#13/#14 respectively via
     the `TRAP #n` → vector `32+n` mapping already documented generically
     in the Amiga module's M68000PRM citation).
  3. Independent second-source cross-check for at least one of the three
     (BIOS): FreeMiNT's actively-maintained `tos.hyp` documentation states
     "The BIOS (Basic Input/Output System) functions represent the lowest
     level interface between the Atari's operating system and hardware,
     and are called via the 680X0 Trap #13." Source:
     `freemint.github.io/tos.hyp/en/About_the_BIOS.html`.

  **Conclusion: the commonly cited GEMDOS=1/BIOS=13/XBIOS=14 numbers are
  correct**, confirmed against a primary developer-documentation source
  (not just repeated folklore).
- **Calling convention** (same shape across all three APIs, confirmed
  verbatim in each "Function Calling Procedure" section): arguments are
  pushed onto the stack **in reverse order**, followed last by a
  `move.w #<opcode>,-(sp)` pushing the 16-bit function number, then the
  `TRAP #n` instruction itself; **the caller is responsible for cleaning up
  the stack afterward** (e.g. `addq.l #4,sp` / `lea 12(sp),sp` patterns
  seen throughout the Compendium's own worked examples) — GEMDOS/BIOS/
  XBIOS do not clean the stack for the caller. All three APIs are
  documented as free to clobber `D0–D2` and `A0–A2` as scratch registers,
  and to overwrite the pushed opcode word itself, so neither should be
  relied on after the call returns. Source: same three "Function Calling
  Procedure" sections cited above (Book 2 p. 2.9, Book 3 p. 3.21, Book 4
  p. 4.19).
- **How this appears in Ghidra's disassembly/decompiler output**: `TRAP
  #1`/`TRAP #13`/`TRAP #14` are plain, fully-defined 68000 opcodes — Ghidra
  disassembles them natively with no gaps (this is generic 68000 SLEIGH
  behavior, not Atari-specific, so no separate primary-source check was
  needed beyond what the Amiga module already established about TRAP
  semantics from the M68000PRM vector table). What Ghidra has **no
  built-in knowledge of** is which function a given call invokes: the
  function number is just a plain 16-bit immediate operand on the
  `move.w #$4B,-(sp)` (or similar) instruction immediately preceding the
  trap, and nothing in a stock Ghidra install maps `$4B` → `Pexec`. This is
  the direct structural analogue of the Amiga module's unnamed `jsr
  -552(a6)` LVO problem: an opcode Ghidra disassembles correctly but can't
  name without external knowledge, and the "external knowledge" here is
  exactly the same kind of lookup table the Compendium itself provides
  (Book 2's opcode-number index, e.g. "75  0x4B  Pexec()  Execute another
  process ... 2.103" — one row per GEMDOS call, cross-referencing the
  Compendium's own page numbers). Confirmed from the *other* side too:
  the community project `czietz/ghidraScripts_for_Atari` (Ghidra
  helper-script collection for Atari binaries) explicitly lists, under
  "Ideas for future development," **"A script to annotate TRAPs (OS calls)
  according to function number"** as work not yet done — i.e. as of that
  project's current state, Ghidra does not auto-annotate GEMDOS/BIOS/XBIOS
  trap calls with function names out of the box, matching the Compendium-
  side reasoning above. Source:
  `github.com/czietz/ghidraScripts_for_Atari` README, "Ideas for future
  development" section (fetched via `gh api
  repos/czietz/ghidraScripts_for_Atari/contents/README.md`).
- **Authoritative source for the call-number tables**: The Atari
  Compendium's Book 2 (GEMDOS), Book 3 (BIOS), and Book 4 (XBIOS) each
  contain a full per-function reference (name, decimal+hex opcode,
  parameters, binding example, availability by GEMDOS/TOS version) plus a
  consolidated numeric-opcode-to-function index table (e.g. the line "75
  0x4B  Pexec()  Execute another process. ... 2.103" comes from exactly
  such an index). This is the same document already cited throughout this
  section — no separate source was needed. `freemint.github.io/tos.hyp`
  functions as a living, openly-hosted equivalent for the same numbers
  (spot-checked for BIOS above) and is the better citation to actually
  point learners at (see §5 on the Compendium's own distribution
  restriction).

## 3. PRG/TOS executable header format

**Full 28-byte (`0x1C`-byte) header, verbatim field table** (source: The
Atari Compendium, "GEMDOS Processes," Book 2 pp. 2.9–2.10, "GEMDOS
executable files ... contain the following file header"):

| Field | Offset | Size | Contents |
|---|---|---|---|
| `PRG_magic` | `0x00` | WORD | magic value `0x601A` |
| `PRG_tsize` | `0x02` | LONG | size of the TEXT segment, bytes |
| `PRG_dsize` | `0x06` | LONG | size of the DATA segment, bytes |
| `PRG_bsize` | `0x0A` | LONG | size of the BSS segment, bytes |
| `PRG_ssize` | `0x0E` | LONG | size of the symbol table, bytes |
| `PRG_res1` | `0x12` | LONG | unused/reserved |
| `PRGFLAGS` | `0x16` | LONG | process-characteristic flag bits (below) |
| `ABSFLAG` | `0x1A` | WORD | non-zero = no relocation fixups present; 0 = fixups present |

Header is exactly `0x1C` (28) bytes; the TEXT segment begins immediately
at offset `0x1C`.

**What follows the header, with exact offset formulas** (same source,
immediately following the field table):

| Region | Offset | Contents |
|---|---|---|
| Text segment | `0x1C` | the program's TEXT segment |
| Data segment | `PRG_tsize + 0x1C` | the program's DATA segment (if any) |
| Symbol table | `PRG_tsize + PRG_dsize + 0x1C` | symbol table (format is compiler/vendor-specific — the Compendium explicitly does not standardize its internal layout: "The symbol table area is used differently by different compiler vendors. Consult them for the format.") |
| Fixup offset | `PRG_tsize + PRG_dsize + PRG_ssize + 0x1C` | one LONG: offset (from file start) of the first longword needing relocation fixup; `0` = no fixups |
| Fixup information | `PRG_tsize + PRG_dsize + PRG_ssize + 0x20` | a byte stream of relocation deltas: `0` = end of list, `1` = advance 254 bytes (no fixup here, keep going), any even value `2–254` = advance that many bytes and apply a fixup to the longword found there |

**`ABSFLAG` caveat worth keeping in the guide verbatim**, since it's an
easy trap for a reverse engineer inspecting real files: "Since some
versions of TOS handle files with this value being non-zero incorrectly,
it is better to represent a program having no fixups with `0` here and
placing a `0` longword as the fixup offset" — i.e. don't assume
`ABSFLAG != 0` reliably means "no relocations, skip the fixup-info parse,"
because some encoders/tools set it to `0` even for a fixup-free binary and
just supply an empty (`0`-length) fixup chain instead. Source: same
Compendium page, `ABSFLAG` row.

**`PRGFLAGS` bit layout** (same source, table immediately following):

| Bits | Meaning |
|---|---|
| 0 (`PF_FASTLOAD`) | if set, clear only the BSS area on load; otherwise clear the entire heap |
| 1 (`PF_TTRAMLOAD`) | if set, program may load into alternative (TT) RAM; otherwise standard RAM only |
| 2 (`PF_TTRAMMEM`) | if set, the program's `Malloc()` calls may be satisfied from TT RAM; otherwise standard RAM only |
| 3 | unused |
| 4–5 | memory-protection class (MultiTOS-era): `0`=`PF_PRIVATE`, `1`=`PF_GLOBAL`, `2`=`PF_SUPERVISOR`, `3`=`PF_READABLE` |
| 6–15 | unused |

Entry-point convention (ties §1 and §3 together): "A process is started
by JMP'ing to BYTE 0 of this [TEXT] segment with the address of your
process's basepage at 4(sp)" — i.e. execution begins at file offset
`0x1C` once loaded, with the basepage pointer already on the stack, no
separate "entry point" field anywhere in the header (unlike, say, an ELF
`e_entry` — the entry point is always simply "the first byte of the TEXT
segment," which is why the header itself carries no entry-address field).
Source: same Compendium section.

## 4. Does Ghidra 12.1.2 have a native PRG/TOS loader?

**No — confirmed definitively, the same two ways the Amiga module
confirmed the absence of a Hunk loader**, against the pinned
`Ghidra_12.1.2_build` tag:

1. **Full `Loader` class listing** under
   `Ghidra/Features/Base/src/main/java/ghidra/app/util/opinion/` (`git
   trees` API, recursive, filtered to files ending `Loader.java`): 37
   classes total — `TenetLoader`, `AbstractLibrarySupportLoader`,
   `AbstractOrdinalSupportLoader`, `AbstractPeDebugLoader`,
   `AbstractProgramLoader`, `AbstractProgramWrapperLoader`, `BinaryLoader`,
   `CoffLoader`, `DbgLoader`, `DecompileDebugXmlLoader`, `DefLoader`,
   `DyldCacheLoader`, `ElfLoader`, `GdtLoader`, `GzfLoader`,
   `IntelHexLoader`, `Loader`, `MSCoffLoader`, `MachoLoader`, `MapLoader`,
   `MotorolaHexLoader`, `MzLoader`, `NeLoader`, `Omf51Loader`, `OmfLoader`,
   `PeLoader`, `PefLoader`, `SomLoader`, `UnixAoutLoader`,
   `UnixAoutProgramLoader`, `XmlLoader`, `ApkLoader`, `CDexLoader`,
   `DexLoader`, `DyldCacheExtractLoader`, `MachoFileSetExtractLoader`,
   `JavaLoader` — **no PRG, TOS, GEMDOS, or Atari-named class anywhere in
   the list.**
2. **Full case-insensitive recursive path search** of every one of the
   24,554 entries in the entire `Ghidra_12.1.2_build` repo tree (via the
   GitHub `git/trees?recursive=true` API) for the substrings `atari`,
   `gemdos`, and `prg`: **zero genuine hits.** The only `atari` substring
   match at all is `MDDataRightReferenceType.java`
   (`Ghidra/Features/MicrosoftDmang/...`), which matches purely because
   "D**ataRi**ghtReferenceType" happens to contain the letters a-t-a-r-i —
   confirmed a false positive by direct string check, not Atari-related in
   any way. `gemdos` and `prg` (as a path fragment) return no matches at
   all.
3. **`68000.opinion` doesn't wire the 68000 language to any Atari-related
   loader**, exactly mirroring what the Amiga module found for Hunk: it
   only pairs the 68000 processor with ELF, PEF ("Preferred Executable
   Format"), Palm Pilot Program, and a.out (`AOUT`) loaders. No GEMDOS/PRG
   entry. Source:
   `Ghidra/Processors/68000/data/languages/68000.opinion` (fetched at
   `Ghidra_12.1.2_build` — full file quoted, 4 `<constraint>` blocks
   total, no others present).

**Practical consequence / community option — lighter-weight than the
Amiga situation, worth calling out as a genuine difference in the guide's
framing**: unlike Amiga (where the community fix is a full third-party
*Loader extension*, `BartmanAbyss/ghidra-amiga`, that must be built/
installed against a matching Ghidra point release), the Atari-side
community project found in this pass —
`github.com/czietz/ghidraScripts_for_Atari` — is a set of plain **Ghidra
scripts** (Python, run from the Script Manager, no extension build/install
step), of which `ImportAtariPRG.py` specifically "imports a TOS program
(PRG, TOS, TTP, APP, ...) into Ghidra. It creates a memory map for TEXT,
DATA and BSS sections from the program header," optionally importing a
DRI/GST-format symbol table if the toolchain produced one. This is a
materially different (lower-friction, no version-pinning-fragility)
workaround than the Amiga module's extension story, and the guide should
say so explicitly rather than implying the same "install a loader
extension" story applies unchanged. (This project's internals — e.g.
exactly how it constructs Ghidra memory blocks or handles the fixup-info
byte stream from §3 — were not reviewed beyond the README description in
this pass.)

## 5. Legal/licensing check

- **GEMDOS/BIOS/XBIOS call numbers and the PRG header format are
  Atari's own published developer specification, not derived from
  copyrighted TOS ROM disassembly.** The Atari Compendium's own
  introduction states its source material as Atari's official developer
  documentation, release notes, and technical support, plus independently
  published third-party developer books (Compute!'s AES/TOS/VDI series,
  the Lattice C Atari Library Manual, the German "Atari Profibuch") — i.e.
  API/ABI documentation Atari itself distributed to third-party developers
  to *write* GEMDOS/BIOS/XBIOS-calling programs, the same relationship the
  Amiga module's RKM/NDK sources have to AmigaOS. Nothing in §2 or §3 above
  required looking at a ROM image or disassembling one. This is consistent
  with the course's no-copyrighted-ROM-content rule.
- **One real caveat, and it's about the specific *document*, not the
  facts it documents**: the Compendium PDF's own title page says "**Not
  for Public Distribution**" (it began life as an author's working-draft
  review copy circulated to developers for feedback, per its own
  introduction: "By providing early copies of the text of this volume I
  hope to accomplish several goals... Avoid any legal problems stemming
  from non-disclosure or copyright questions"). In practice it has been
  openly mirrored across the Atari community for decades with no known
  objection (`info-coach.fr`, `cd.textfiles.com`, `bus-error.nokturnal.pl`,
  `tho-otto.de` hypertext version, etc.), but the guide should **cite the
  facts (trap numbers, header offsets, opcode tables) rather than bundle
  or redistribute the Compendium PDF itself**, and prefer linking to the
  actively-maintained, openly-hosted `freemint.github.io/tos.hyp`
  restatement of the same API documentation where a single canonical link
  is needed — exactly the role FreeMiNT's docs already played as the
  independent BIOS-TRAP-number cross-check in §2.
- **If the guide ever wants ROM-level material** (e.g. an exercise poking
  at an actual TOS boot ROM image, the Atari-side analogue of the Amiga
  module's Kickstart-in-memory-map note) — real Atari TOS ROM images
  *are* Atari's copyrighted code and must not be bundled, exactly as with
  Kickstart. Unlike the Amiga side, though, there's a directly-applicable
  legally-clean substitute already in wide RE-community use: **EmuTOS**
  (`github.com/emutos/emutos`), a free/open-source, **GPLv2-licensed**
  reimplementation of TOS built from Digital Research's GPL'd original GEM
  sources, explicitly designed as a drop-in ROM replacement for
  emulators/real hardware without requiring the real copyrighted ROM. The
  `czietz/ghidraScripts_for_Atari` project's `ImportAtariTOSROM.py` script
  explicitly supports loading EmuTOS symbol maps, confirming it's already
  a recognized/used substitute in the Atari Ghidra-RE community, not just
  a theoretical option. Worth keeping in mind for a later exercises phase
  if this module ever wants a real (but legally clean) boot-ROM walkthrough
  — no such exercise exists yet in this Phase 7 research pass, this is
  purely a note for that possible future case.

---

## Unresolved / needs further verification

- **Whether classic (pre-MultiTOS) `Pexec()` actually switches the CPU to
  user mode before jumping to a freshly loaded program, vs. leaving it in
  supervisor mode and relying on the program to call `Super()` itself.**
  The Compendium's XBIOS chapter states the *normative* claim ("Normal
  programs always execute in user mode") but this pass found no primary
  Atari document that describes what `Pexec()` itself does to the
  processor's mode bit at the moment it hands off to the child process.
  Community discussion (Atari-Forum threads on entering/leaving supervisor
  mode) is consistent with, but does not conclusively confirm either way,
  the commonly-repeated claim that in practice most single-tasking-era ST
  software runs entirely in supervisor mode without ever calling `Super()`.
  This matters for how confidently the guide can frame "watch for
  `Super()` calls as a mode-switch signal" (§1) — worth a follow-up pass
  against a GEMDOS/BIOS source-level document (e.g. an EmuTOS source read,
  since EmuTOS is GPL'd and its `Pexec()` implementation is directly
  readable) if a later phase needs the stronger claim.
- **Exact provenance of the individual Compendium mirrors' HTML/PDF
  transcription** — this pass fetched and grep'd the `info-coach.fr` PDF
  copy directly (via `pdftotext -layout`) rather than trusting a
  web-summarized excerpt, which is why quotes above include exact
  surrounding context, but did not cross-check that PDF's OCR/transcription
  accuracy byte-for-byte against, say, the original 1992 print/scan. Given
  the header-offset table, opcode numbers, and TRAP numbers were all
  independently cross-checked (opcode-table entry vs. per-function
  reference-page entry; TRAP numbers vs. the separate vector-table
  appendix; BIOS TRAP number vs. an entirely separate FreeMiNT source),
  this is treated as a low risk, not a real gap.
- **`czietz/ghidraScripts_for_Atari` internals**: confirmed to exist,
  confirmed by its own README to provide `ImportAtariPRG.py` (PRG/TOS/TTP/
  APP header-driven memory-map creation, optional DRI/GST symbol import),
  `ImportAtariTOSROM.py` (TOS/EmuTOS ROM import with optional EmuTOS symbol
  map), and a MiNTLib Function ID database — but this pass did not review
  the actual Python source to confirm implementation details (e.g. exactly
  how the fixup-info byte stream from §3 gets applied, or whether TEXT/
  DATA/BSS become separate named Ghidra memory blocks or one combined
  block). Worth a closer look once a later phase actually needs to
  recommend/use it for an exercise, the same "defer until an exercises
  phase needs it" treatment the Amiga module gave `ghidra-amiga`.
- **Live Ghidra verification in general**: as with every prior module, no
  local Ghidra install was available for this research pass. The
  "TRAP #n is disassembled natively but the function number isn't
  auto-resolved" claim (§2) is inferred from generic 68000 SLEIGH behavior
  already established for the Amiga module plus the czietz README's own
  "not yet done" framing, not from watching Ghidra's Listing window on a
  real Atari PRG import — worth a sanity check against an installed
  12.1.2 with an actual GEMDOS-calling binary once convenient.
