# 68000/TOS Differences From Amiga

This guide assumes the CPU-level material from
`02-retro-amiga/01-68000-recap.md` (register set, condition codes, addressing
modes as Ghidra prints them, MOVEM/LINK-UNLK/TRAP mechanics) — none of that
is repeated here. What follows is only what actually changes when the
platform under the same 68000 is TOS instead of AmigaOS.

## Endianness — no change

Ghidra disassembles Atari ST code with the same `68000:BE:32:default`
language used for Amiga: `68000.ldefs` declares the processor big-endian
unconditionally, not per-platform. Atari ST/STE shipped the plain MC68000;
later TT/Falcon models moved to the 68030/68040, all still big-endian 68000
family. Nothing to relearn here — it's the identical ISA, just a different
OS sitting on top of it.

## No fixed "read address 4" convention

AmigaOS's `ExecBase` lives at one well-known **absolute address**, `$4` —
every running program reads it to find the system (see
`02-retro-amiga/03-exec-library-kickstart.md`). TOS has nothing like it.
Instead, GEMDOS hands each **individual process** a pointer to its own
private **basepage**, passed as a stack argument at process-start time —
not a fixed memory location. A program reaches the *system* indirectly
instead, through `TRAP` calls (see the next guide) rather than through a
shared fixed-address global structure.

Canonical startup code confirms exactly how a program picks the pointer up:

```
move.l 4(sp),a0   ; obtain pointer to basepage
```

If you're used to scanning Amiga disassembly for `move.l 4.w,A6`-style
reads of address 4, drop that habit here — on Atari ST, watch the first few
instructions after entry for a read of `4(sp)` instead.

## The basepage structure

Analogous in *role* to Amiga's `ExecBase`-plus-hunk-table, but laid out as a
flat, fixed-size 256-byte struct at a process-specific address rather than a
shared fixed location:

| Field | Offset | Size | Meaning |
|---|---|---|---|
| `p_lowtpa` | `0x00` | LONG | base of the Transient Program Area (TPA) |
| `p_hitpa` | `0x04` | LONG | top of the TPA + 1 |
| `p_tbase` | `0x08` | LONG | base of the TEXT segment |
| `p_tlen` | `0x0C` | LONG | length of the TEXT segment |
| `p_dbase` | `0x10` | LONG | base of the DATA segment |
| `p_dlen` | `0x14` | LONG | length of the DATA segment |
| `p_bbase` | `0x18` | LONG | base of the BSS segment |
| `p_blen` | `0x1C` | LONG | length of the BSS segment |
| `p_dta` | `0x20` | LONG | pointer to the process's DTA (Disk Transfer Address) |
| `p_parent` | `0x24` | LONG | pointer to the parent process's basepage |
| `p_reserved` | `0x28` | LONG | unused |
| `p_env` | `0x2C` | LONG | pointer to the process's environment string |
| `p_undef` | `0x30` | 80 bytes | unused |
| `p_cmdlin` | `0x80` | 128 bytes | copy of the command-line image |

`0x80 + 128 = 0x100` = 256 bytes total. When you see code walking a struct
off a stack-supplied pointer near a program's entry, with fields at these
exact offsets, you're looking at basepage access — a strong signal the
binary is a GEMDOS program even before you've confirmed the header (see the
[PRG header format](03-prg-tos-executable-format.md) guide).

## Stack shrink: `Mshrink()`

GEMDOS hands a fresh process the *entire remaining TPA*, not a
right-sized allocation — a well-behaved program is expected to compute how
much it actually needs and give the rest back with `Mshrink()` (GEMDOS
opcode `0x4A`, called via `TRAP #1`; see the next guide for the calling
convention). Most C runtimes do this in their startup code, so it typically
shows up as one of the first GEMDOS calls after basepage setup — recognize
`move.w #$4A,-(sp)` / `trap #1` early in a `_start`-like function as this
housekeeping call, not application logic. This has no Amiga parallel:
`exec.library` never hands out a whole-remaining-RAM block for a process to
voluntarily shrink.

## User mode, supervisor mode, and `Super()`

USP/SSP banking itself is generic 68000 hardware, already covered in the
Amiga recap. What's platform-specific is that TOS actually uses the
distinction as an access-control boundary: "Normal programs always execute
in user mode. Programs operating in user mode... have less memory access
privileges than those operating in supervisor mode... any memory reads or
writes to locations $0–$7FF or memory-mapped I/O must be made in supervisor
mode." `Super()` (GEMDOS opcode `0x20`, via `TRAP #1`) is the documented way
a program requests supervisor mode (or drops back to user mode), returning
the old SSP.

> **Open question, flagged rather than asserted:** whether classic
> single-tasking `Pexec()` actually *switches to* user mode before jumping
> to a freshly loaded program, or leaves the CPU in whatever mode it
> inherited (often supervisor) and trusts the program to call `Super()`
> itself, isn't settled by a primary source this course could confirm —
> see `RESEARCH-NOTES.md`'s Unresolved section. Community consensus is that
> plenty of ST games/demos never call `Super()` at all and freely poke
> hardware directly, which is consistent with either story.

Practical takeaway either way: unlike Amiga (where custom-chip registers
are just plain memory-mapped with no privilege gate at all — see
`02-retro-amiga/04-custom-chip-registers.md`), on Atari ST a `Super()` call
pattern —

```
move.w #$20,-(sp)
trap   #1
```

— is worth flagging as "this code is about to touch hardware or low memory
directly." It's a genuine RE signal on this platform that has no equivalent
on the Amiga side.

---

**Self-check:** you're looking at a freshly-imported binary and want to
confirm it's a GEMDOS program before you've even found the PRG header —
what's one instruction-level pattern near the entry point that would tell
you? → A read of `4(sp)` shortly after entry (loading the basepage
pointer), often followed by a `TRAP #1` with opcode `$4A` in `D0`/pushed on
the stack (`Mshrink()`) — neither has an Amiga equivalent, since Amiga
programs never receive a basepage and never need to shrink a TPA.
