# Amiga / 68000 Cheatsheet

One-page reference for this module. Details, sourcing, and self-checks are in
the numbered guides — this page is deliberately just the tables. Print via
your browser's "Print to PDF" (Ctrl/Cmd+P) for a physical copy.

## 68000 core

| Registers | D0-D7 (32-bit data), A0-A7 (32-bit address), PC, CCR (8-bit) |
|---|---|
| Stack pointer | A7 - banked: USP (user mode) / ISP-MSP (supervisor mode) |
| CCR flags (bit4->0) | X N Z V C |
| Endianness | Big-endian |
| `(An)` `(An)+` `-(An)` `(d16,An)` `(d8,An,Xn)` | Register Indirect, Postinc, Predec, Displacement, Indexed |
| `(xxx).W` `(xxx).L` `#<xxx>` | Absolute Short/Long, Immediate |
| `MOVEM` register list | printed space-separated (`D2 D3 D4 A2`), never as a range |
| `LINK An,#d16` / `UNLK An` | push An, An=SP, SP+=d16  /  SP=An, pop An |
| `TRAP #n` | vectors 32-47 (n=0-15) |

## exec.library / Kickstart

| SysBase/ExecBase | at address `$4` - the one fixed absolute address in the system |
| LVO reserved vectors | `OPEN=-6` `CLOSE=-12` `EXPUNGE=-18` `RESERVED=-24` |
| LVO formula | `LVO = -(N*6)`, user functions continue from `-30` upward |
| `OpenLibrary` LVO | `-552` — `JSR -552(A6)` with SysBase in A6, name in A1, version in D0 |
| Recognize a library call | `move.l 4.w,An` ... later `jsr <neg>(An)` |
| Kickstart ROM (A500/A1000/A2000) | `$FC0000`-`$FFFFFF` (256K) |

## Hunk executable block IDs (`doshunks.h`)

| 999 UNIT | 1000 NAME | 1001 CODE | 1002 DATA | 1003 BSS |
|---|---|---|---|---|
| 1004 RELOC32 | 1005 RELOC16 | 1006 RELOC8 | 1007 EXT | 1008 SYMBOL |
| 1009 DEBUG | 1010 END | 1011 HEADER | 1013 OVERLAY | 1014 BREAK |

Minimal load file: `HEADER -> CODE -> RELOC32 -> END -> DATA -> RELOC32 -> END -> BSS -> END`.
**No native Ghidra loader** — use `BartmanAbyss/ghidra-amiga` (version-pinned
to a specific Ghidra point release) or manual Raw Binary per hunk.

## Custom chip registers (base `$DFF000`)

| Reg | Off | R/W | Reg | Off | R/W |
|---|---|---|---|---|---|
| DMACONR | $002 | R | DMACON | $096 | W |
| INTENAR | $01C | R | INTENA | $09A | W |
| INTREQR | $01E | R | INTREQ | $09C | W |
| COP1LCH/L | $080/$082 | W | COP2LCH/L | $084/$086 | W |
| BLTCON0/1 | $040/$042 | W | BPLCON0 | $100 | W |
| DIWSTRT/STOP | $08E/$090 | W | AUD0LCH/LEN/PER/VOL | $0A0/$0A4/$0A6/$0A8 | W |

Read/write pairs live at *different* offsets (`DMACON` write `$096` vs.
`DMACONR` read `$002`) — seeing both is normal, not a disassembly error.
Bit 15 of a write to DMACON/INTENA/INTREQ selects SET vs CLEAR for the other
written bits. Audio channels 1-3 mirror the AUD0* block at `+$10` steps each.
