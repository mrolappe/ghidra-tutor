# exec.library & Kickstart Basics

Almost every Amiga disassembly you look at eventually calls into the OS —
recognizing *how* that call shows up in Ghidra, with no symbol attached, is
the point of this guide.

## exec.library — the one fixed address on the system

"The Multitasking Executive, better known as Exec, is the heart of the
Amiga's operating system. All other systems in the Amiga rely on it to
control multitasking, to manage the message-based interprocess communications
system, and to arbitrate access to system resources." Source: *Amiga ROM
Kernel Reference Manual: Libraries* ("RKM Libraries"), Ch. 17.

Every other structure in the system is reached indirectly, starting from one
fixed spot: "the first step is to fetch the address of the exec.library from
location 4; this is the only absolute memory location in the system." The
long-word at address `$4` always holds the running system's
`ExecBase`/`SysBase` pointer. Source: AHRM Appendix D.

## Library Vector Offsets (LVOs)

Libraries don't export symbols the way a modern shared object does. Instead:
"Each function's entry in the jump table ... is always a constant (negative)
offset from the library base ... An application enters a library function by
doing a jump to subroutine (JSR) to the proper negative offset (LVO) from the
address of the library base. The library vector itself is a jump instruction
(JMP) to the actual library function." Source: RKM Libraries, Ch. 17, "Library
Vector Offsets (LVOs)".

Every library reserves its first four vectors for housekeeping, at fixed
offsets: `OPEN = -6`, `CLOSE = -12`, `EXPUNGE = -18`, `RESERVED = -24`.
User-callable functions continue from `-30` upward in steps of 6 bytes (one
`JMP` per vector: `LVO = -(N*6)` for the Nth function). "A function's LVO is
always the same on every system" — the offset is stable across Kickstart
versions even though the jump target it points to isn't. Source: RKM
Libraries, Ch. 17, Fig. 17-1.

`OpenLibrary` — the call that turns a library name string into a usable base
pointer — sits at LVO `-552` (consistent with the `-(N*6)` formula: function
#92 counting past the 4 reserved vectors). This exact number is
well-corroborated across independent developer references but wasn't
confirmed here against the literal NDK `.fd`/pragma file itself — see this
module's `RESEARCH-NOTES.md` if you want to chase that down further. Called
as: `SysBase` (from address `4`) loaded into `A6`, the library name pointer in
`A1`, minimum version in `D0`, then `JSR -552(A6)`. Once given a named
constant this is written `JSR _LVOOpenLibrary(A6)` — exactly what NDK
`.fd`/pragma files exist to generate.

## Why Ghidra shows `jsr -552(a6)` with no name

Structurally, `-552(A6)` is nothing more than ordinary 68000 Address
Register Indirect with Displacement addressing — see the [68000
recap](01-68000-recap.md) — used as a call target. Ghidra has no built-in
knowledge that `A6` conventionally holds a library base at that point in the
code, or that negative displacements off a library base form a jump table; it
just disassembles the literal operand. Nothing in a plain binary import ties
that address to a name. Loading Amiga NDK `.fd`-derived symbol data (a job
for the loader extension mentioned in the [Hunk format
guide](02-hunk-executable-format.md), or manual data-type import) is what
lets a later workflow resolve `-552(A6)` to `_LVOOpenLibrary` — until then,
recognize the *pattern* (small negative constant, `An` register, right after
a `move.l 4.w,An` or a saved library-base load) even without the name.

## Kickstart ROM in the memory map

Per AHRM Appendix D's per-model memory maps:

| Model | Kickstart ROM range | Notes |
|---|---|---|
| A1000 / A500 / A2000 | `$FC0000`–`$FFFFFF` | 256K System ROM |
| A3000-class | `$F80000`–`$FFFFFF` | 512K "High ROM"; `$F00000`–`$F7FFFF` reserved for a disabled-by-default Diagnostic ROM |

Custom chip registers sit at `$DFF000`–`$DFFFFF` on the same map — see
[custom chip registers](04-custom-chip-registers.md).

---

**Self-check:** you see `move.l 4.w,A6` followed a few instructions later by
`jsr -552(A6)` — what's happening, without any symbol names present? →
`A6` is being loaded with `SysBase`/`ExecBase` (the one fixed pointer at
address `4`), then a call is made through the LVO jump table at offset
`-552`, which is `exec.library`'s `OpenLibrary`.
