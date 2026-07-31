# Atari ST / TOS Cheatsheet

One-page reference for this module. Same 68000 core as Amiga (see
`02-retro-amiga/cheatsheet-print.md` for those registers/addressing-mode
tables — not repeated here) with a different OS on top. Details, sourcing,
and self-checks are in the numbered guides. Print via your browser's
"Print to PDF" (Ctrl/Cmd+P) for a physical copy.

## The three system APIs

| API | TRAP | Vector | Handler | Layer |
|---|---|---|---|---|
| GEMDOS | `TRAP #1` | `0x21` | `$84` | filesystem, process, memory |
| BIOS | `TRAP #13` | `0x2D` | `$B4` | low-level device I/O |
| XBIOS | `TRAP #14` | `0x2E` | `$B8` | extended/hardware-specific |

Calling shape: push args in reverse order, push the 16-bit function number,
then `TRAP #n`. **Caller** cleans the stack afterward.

| Common call | Opcode | Trap |
|---|---|---|
| `Mshrink()` — shrink to needed memory | `$4A` | #1 |
| `Pexec()` — execute another process | `$4B` | #1 |
| `Super()` — request/drop supervisor mode | `$20` | #1 |

Recognize `Super()` on sight: `move.w #$20,-(sp)` / `trap #1` — a genuine RE
signal that hardware or low memory is about to be touched directly (no
Amiga equivalent — custom chips there are ungated).

## No fixed SysBase — the basepage instead

No address-4 convention like Amiga. Program picks up its basepage with
`move.l 4(sp),a0` near entry — 256 bytes total:

| Field | Off | Field | Off |
|---|---|---|---|
| `p_lowtpa`/`p_hitpa` | `0x00`/`0x04` | `p_dta` | `0x20` |
| `p_tbase`/`p_tlen` | `0x08`/`0x0C` | `p_parent` | `0x24` |
| `p_dbase`/`p_dlen` | `0x10`/`0x14` | `p_env` | `0x2C` |
| `p_bbase`/`p_blen` | `0x18`/`0x1C` | `p_cmdlin` | `0x80` (128 bytes) |

## PRG/TOS header (28 bytes, `0x00`-`0x1B`)

| Field | Off | Size | | Field | Off | Size |
|---|---|---|---|---|---|---|
| `PRG_magic` (`0x601A`) | `0x00` | WORD | | `PRG_res1` | `0x12` | LONG |
| `PRG_tsize` | `0x02` | LONG | | `PRGFLAGS` | `0x16` | LONG |
| `PRG_dsize` | `0x06` | LONG | | `ABSFLAG` | `0x1A` | WORD |
| `PRG_bsize` | `0x0A` | LONG | | TEXT starts | `0x1C` | — |
| `PRG_ssize` | `0x0E` | LONG | | | | |

No entry-point field — always byte 0 of TEXT (`0x1C`). `ABSFLAG != 0` should
mean "no fixups" but some TOS versions mishandle it — check the fixup-offset
LONG at `tsize+dsize+ssize+0x1C` instead (`0` = none).

**No native Ghidra loader.** Lighter-weight than Amiga's extension: try
`czietz/ghidraScripts_for_Atari` (plain Ghidra scripts, no build step) before
setting up a manual TEXT/DATA/BSS memory map by hand.
