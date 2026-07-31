# KERNAL/BASIC-ROM References in Disassembly

Almost every non-trivial C64 machine-language program eventually calls
into the KERNAL — the ROM operating system that handles screen output,
keyboard input, and serial/tape I/O. Recognizing those calls *by address*
in Ghidra's Listing, with no symbol attached, is the C64 module's version
of the same problem the Amiga module solved for LVOs
(`02-retro-amiga/03-exec-library-kickstart.md`) and the Atari ST module
solved for GEMDOS/BIOS/XBIOS `TRAP` calls
(`03-retro-atari-st/02-gemdos-bios-xbios-calls.md`).

## The KERNAL jump table: $FF81–$FFF3

Unlike Amiga's negative-offset LVO table or Atari's `TRAP`+opcode-number
scheme, the C64 KERNAL exposes its API as a fixed table of `JMP`
instructions at the very top of the address space — one 3-byte `JMP` per
function, always at the same address across every KERNAL ROM revision.
Calling a KERNAL routine is simply `JSR $FFxx` to one of these entries.

Full table (source: `sta.c64.org/cbm64krnfunc.html`, "Commodore 64
standard KERNAL functions" — official-style reference documenting the
public jump-table API, not a ROM disassembly):

| Address | Function | Address | Function |
|---|---|---|---|
| `$FF81` | `SCINIT` — init VIC/screen | `$FFC0` | `OPEN` — open a logical file |
| `$FF84` | `IOINIT` — init CIAs/SID/IRQ | `$FFC3` | `CLOSE` — close a logical file |
| `$FF87` | `RAMTAS` — init/test RAM, set memory pointers | `$FFC6` | `CHKIN` — open channel for input |
| `$FF8A` | `RESTOR` — restore default I/O vectors | `$FFC9` | `CHKOUT` — open channel for output |
| `$FF8D` | `VECTOR` — read/set I/O vector table | `$FFCC` | `CLRCHN` — restore default I/O channels |
| `$FF90` | `SETMSG` — control OS message printing | `$FFCF` | **`CHRIN`** — read a character from the input channel |
| `$FF93` | `LSTNSA` — send LISTEN secondary address | `$FFD2` | **`CHROUT`** — write a character to the output channel |
| `$FF96` | `TALKSA` — send TALK secondary address | `$FFD5` | `LOAD` — load RAM from a device |
| `$FF99` | `MEMTOP` — read/set top of memory | `$FFD8` | `SAVE` — save RAM to a device |
| `$FF9C` | `MEMBOT` — read/set bottom of memory | `$FFDB` | `SETTIM` — set the software clock |
| `$FF9F` | `SCNKEY` — scan the keyboard | `$FFDE` | `RDTIM` — read the software clock |
| `$FFA2` | `SETTMO` — set IEC bus timeout | `$FFE1` | `STOP` — test the STOP key/scan queue |
| `$FFA5` | `IECIN` — input byte, serial (IEC) bus | `$FFE4` | **`GETIN`** — get a character from the input queue |
| `$FFA8` | `IECOUT` — output byte, serial (IEC) bus | `$FFE7` | `CLALL` — close all files |
| `$FFAB` | `UNTALK` — command serial bus device to UNTALK | `$FFEA` | `UDTIM` — update the software clock |
| `$FFAE` | `UNLSTN` — command serial bus device to UNLISTEN | `$FFED` | `SCREEN` — read screen format (rows/columns) |
| `$FFB1` | `LISTEN` — command serial bus device to LISTEN | `$FFF0` | `PLOT` — read/set cursor position |
| `$FFB4` | `TALK` — command serial bus device to TALK | `$FFF3` | `IOBASE` — read base address of I/O devices |
| `$FFB7` | `READST` — read I/O status word | | |
| `$FFBA` | `SETLFS` — set logical file parameters | | |
| `$FFBD` | `SETNAM` — set filename | | |

The three bolded entries (`CHRIN`/`CHROUT`/`GETIN`) are by far the most
common in ordinary program disassembly — `JSR $FFD2` (print one character)
in particular shows up constantly, the KERNAL equivalent of `putchar`.

## How this looks in Ghidra

A raw C64 binary import gives Ghidra no knowledge that `$FFD2` means
anything special — it's just an address, disassembled correctly (`JSR
$FFD2`) but with no symbol. This is structurally identical to the
Amiga/Atari unnamed-call problem: the *opcode* is fully understood, the
*meaning of the operand* isn't, because that meaning lives in a
platform-specific API table external to the CPU architecture itself.
Practical fix: manually create labels at these 40 addresses (or import
them as a small script/FID source) before annotating a KERNAL-heavy
binary — turning `JSR $FFD2` into `JSR CHROUT` immediately makes call
sites self-documenting, the same payoff [core-workflows' Function
ID](../01-core-workflows/04-function-id.md) describes for recurring
library code in general.

Recognizing the *pattern* even without labels: a `JSR` (or `JMP`) whose
target falls inside `$FF81`–`$FFF3` is calling the KERNAL, full stop — no
other legitimate jump target lives in that 115-byte window, since it's
entirely consumed by this table.

## BASIC ROM: a narrower target for ML disassembly

The BASIC interpreter ROM (`$A000`–`$BFFF` when banked in, see [memory map
& bank switching](02-memory-map-bank-switching.md)) is far less often a
direct call target from hand-written machine code — it exists mainly to
run tokenized BASIC programs and to give a `SYS` statement a way to jump
into ML. The one BASIC-ROM interaction worth recognizing on sight: a
`.PRG` that starts with a short tokenized BASIC line calling
`SYS <address>` is the standard, universal way C64 programs bootstrap from
"loaded" to "running machine code" — covered from the file-format side in
[PRG/cartridge formats](04-prg-cartridge-formats.md).

---

**Self-check:** you see `JSR $FFCF` immediately followed by a `CMP #$0D`
— what's the code doing, without any labels present? → `$FFCF` is
`CHRIN` (read one character from the current input channel); comparing
the result against `#$0D` (carriage return) means this is a
line-input-style loop, reading characters until it sees a CR — the same
recognizable shape as a `getchar()`/newline-check loop on any other
platform.
