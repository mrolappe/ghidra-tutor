# C64 / 6502/6510 Cheatsheet

One-page reference for this module. Details, sourcing, and self-checks are
in the numbered guides — this page is deliberately just the tables. Print
via your browser's "Print to PDF" (Ctrl/Cmd+P) for a physical copy.

## 6502 core

| Registers | A, X, Y (8-bit), SP (8-bit, page-fixed), PC (16-bit), P (8-bit flags) |
|---|---|
| P flags (bit7->0) | N V - B D I Z C |
| Stack | fixed `$0100`-`$01FF`, SP indexes into it (max depth 256 bytes) |
| Vectors | NMI `$FFFA`-`$FFFB`, RESET `$FFFC`-`$FFFD`, IRQ/BRK `$FFFE`-`$FFFF` |
| `#$xx` `$xx` `$xx,X/Y` `$xxxx` `$xxxx,X/Y` | Immediate, Zero page, Zero page indexed, Absolute, Absolute indexed |
| `($xx,X)` `($xx),Y` `($xxxx)` | Indexed indirect, Indirect indexed, Indirect (JMP only) |

**No separate 6510 language in Ghidra** — only `6502:LE:16:default` and
`65C02:LE:16:default` exist. The 6510's `$00`/`$01` I/O port is invisible to
Ghidra's processor spec and shows up as plain zero-page RAM.

## Bank switching: `$00` (DDR) / `$01` (port)

| Bit | Weight | Name | High (1) effect |
|---|---|---|---|
| 0 | 1 | `LORAM` | BASIC ROM banked in at `$A000`-`$BFFF` |
| 1 | 2 | `HIRAM` | KERNAL ROM banked in at `$E000`-`$FFFF` |
| 2 | 4 | `CHAREN` | I/O banked in at `$D000`-`$DFFF` (else Char ROM) |

Default/power-up mode: **31** (`LORAM=HIRAM=CHAREN=1`, all latch bits high).
`$D000`-`$DFFF` can be Char ROM, RAM, *or* I/O depending on state — always
check `CHAREN` before reading an address in that range.

## KERNAL jump table (`$FF81`-`$FFF3`, fixed across all ROM revisions)

| Addr | Fn | Addr | Fn | Addr | Fn | Addr | Fn |
|---|---|---|---|---|---|---|---|
| FF81 SCINIT | FF84 IOINIT | FF87 RAMTAS | FF8A RESTOR | FF8D VECTOR | FF90 SETMSG | FF93 LSTNSA | FF96 TALKSA |
| FF99 MEMTOP | FF9C MEMBOT | FF9F SCNKEY | FFA2 SETTMO | FFA5 IECIN | FFA8 IECOUT | FFAB UNTALK | FFAE UNLSTN |
| FFB1 LISTEN | FFB4 TALK | FFB7 READST | FFBA SETLFS | FFBD SETNAM | FFC0 OPEN | FFC3 CLOSE | FFC6 CHKIN |
| FFC9 CHKOUT | FFCC CLRCHN | **FFCF CHRIN** | **FFD2 CHROUT** | FFD5 LOAD | FFD8 SAVE | FFDB SETTIM | FFDE RDTIM |
| FFE1 STOP | **FFE4 GETIN** | FFE7 CLALL | FFEA UDTIM | FFED SCREEN | FFF0 PLOT | FFF3 IOBASE | |

Bold = most common in ordinary disassembly.

## VIC-II ($D000-$D02E) / SID ($D400-$D418)

| VIC-II | | SID (per voice, +7 per voice) | |
|---|---|---|---|
| `$D011`/`$D016` | Control reg 1/2 | freq lo/hi | +0/+1 |
| `$D012` | RASTER line | pulse width lo/hi | +2/+3 |
| `$D015`/`$D01D`/`$D017` | sprite enable/X-exp/Y-exp | control reg | +4 |
| `$D018` | screen/char mem pointers | attack/decay, sustain/release | +5/+6 |
| `$D020` / `$D021`-`24` | border / background colors | filter cutoff/res/mode+vol | `$D415`-`18` |

## PRG / CRT formats

PRG: 2-byte little-endian load address, then raw bytes (conventionally
`$0801`). CRT: `"C64 CARTRIDGE  "` signature, header-length LONG at
`$0010` (usually `$40`), `EXROM`/`GAME` bytes at `$0018`/`$0019`, then
`CHIP` packets (type/bank/load-addr/size at `+$08`/`+$0A`/`+$0C`/`+$0E`).
Generic cartridge: ROML always `$8000`, ROMH at `$A000` or `$E000`.

**No native Ghidra loader for either** — manual Raw Binary at the header's
load address is the standard path; `jamesham/ghidra-commodore`'s CRT loader
exists but is unreleased/source-only.
