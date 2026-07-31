# PRG/TOS Executable Format

Unlike the Amiga's block-sequence Hunk format
(`02-retro-amiga/02-hunk-executable-format.md`), a GEMDOS executable (`.PRG`
/ `.TOS` / `.TTP` / `.APP`) is a single flat header followed by
segment data — closer in spirit to a classic a.out layout. See the module
README for the full-file diagram; this guide is the field-by-field
reference.

## The 28-byte header

| Field | Offset | Size | Contents |
|---|---|---|---|
| `PRG_magic` | `0x00` | WORD | magic value `0x601A` |
| `PRG_tsize` | `0x02` | LONG | TEXT segment size, bytes |
| `PRG_dsize` | `0x06` | LONG | DATA segment size, bytes |
| `PRG_bsize` | `0x0A` | LONG | BSS segment size, bytes |
| `PRG_ssize` | `0x0E` | LONG | symbol table size, bytes |
| `PRG_res1` | `0x12` | LONG | reserved |
| `PRGFLAGS` | `0x16` | LONG | process-characteristic flags, see below |
| `ABSFLAG` | `0x1A` | WORD | non-zero = no relocation fixups present; `0` = fixups present |

28 (`0x1C`) bytes total. The TEXT segment begins immediately at `0x1C`.

`0x601A` as the first word is the fast way to eyeball whether an imported
binary is a GEMDOS executable before you've looked at anything else — it's
the direct analogue of checking for `HUNK_HEADER` (`0x000003F3`) on the
Amiga side.

### `ABSFLAG`, and a trap worth knowing before you trust it

Some versions of TOS handle a non-zero `ABSFLAG` incorrectly, so
well-behaved tools set it to `0` and instead supply an empty (zero-length)
fixup chain to signal "no relocations" — i.e. **don't assume `ABSFLAG != 0`
reliably means "skip the fixup-info parse."** Check the actual fixup offset
field (below) regardless of what `ABSFLAG` says.

### `PRGFLAGS` bits

| Bits | Meaning |
|---|---|
| 0 (`PF_FASTLOAD`) | set: clear only BSS on load; clear: clear the whole heap |
| 1 (`PF_TTRAMLOAD`) | set: program may load into TT (alternative) RAM |
| 2 (`PF_TTRAMMEM`) | set: `Malloc()` calls may be satisfied from TT RAM |
| 3 | unused |
| 4–5 | memory-protection class (MultiTOS-era): `0`=private, `1`=global, `2`=supervisor, `3`=readable |
| 6–15 | unused |

## What follows the header

| Region | Offset | Contents |
|---|---|---|
| Text segment | `0x1C` | the program's code |
| Data segment | `PRG_tsize + 0x1C` | initialized data (if any) |
| Symbol table | `PRG_tsize + PRG_dsize + 0x1C` | format is compiler/vendor-specific — the header only records its size, not its layout |
| Fixup offset | `PRG_tsize + PRG_dsize + PRG_ssize + 0x1C` | one LONG: file offset of the first longword needing relocation; `0` = no fixups |
| Fixup stream | `PRG_tsize + PRG_dsize + PRG_ssize + 0x20` | byte stream of relocation deltas: `0` = end of list; `1` = advance 254 bytes, no fixup here; any even value `2`–`254` = advance that many bytes and fix up the longword found there |

## Entry point and the basepage handoff

There's no separate entry-point field anywhere in the header — unlike, say,
an ELF `e_entry`. A GEMDOS loader always jumps to byte 0 of the TEXT
segment (file offset `0x1C`), with the new process's basepage pointer
already sitting at `4(sp)` — exactly the handoff described in the previous
guide. The header's job is purely to describe segment *sizes* so the loader
knows how much memory to reserve and where each region starts; where
execution begins is a fixed convention, not a stored value.

## No native Ghidra loader — and a lighter-weight community option than Amiga's

Same situation as the Amiga module found for Hunk
(`02-retro-amiga/02-hunk-executable-format.md`): checked against the
`Ghidra_12.1.2_build` source tree the same way — the full `Loader` class
list under `ghidra/app/util/opinion/` has nothing PRG/TOS/GEMDOS/Atari-named,
a full-tree search for `atari`/`gemdos`/`prg` turns up nothing genuine, and
`68000.opinion` only pairs the 68000 language with ELF, PEF, Palm Pilot
Program, and a.out — no GEMDOS entry. A raw PRG import into Ghidra needs
manual memory-map setup (TEXT/DATA/BSS regions at the sizes/offsets from
the table above) unless you use a loader helper.

Unlike Amiga's fix — a full third-party *Loader extension*
(`BartmanAbyss/ghidra-amiga`) that has to be built and version-matched
against a specific Ghidra point release — the Atari-side community option,
[`czietz/ghidraScripts_for_Atari`](https://github.com/czietz/ghidraScripts_for_Atari),
is a lighter-weight set of plain **Ghidra scripts** (run from the Script
Manager, no build/install step): `ImportAtariPRG.py` reads the header above
and builds the TEXT/DATA/BSS memory map directly, optionally importing a
DRI/GST-format symbol table if the toolchain produced one. Worth trying
before setting up a manual memory map by hand.

---

**Self-check:** you're given a raw file and told it's "probably a GEMDOS
program." What two things do you check, using only the header, to confirm
it and know where the TEXT segment starts? → The first word should be
`0x601A` (the PRG magic); the TEXT segment then always starts at fixed
offset `0x1C`, regardless of `PRG_tsize`/`PRG_dsize`/etc. — those fields
tell you where DATA, the symbol table, and the fixup info start, not where
TEXT does.
