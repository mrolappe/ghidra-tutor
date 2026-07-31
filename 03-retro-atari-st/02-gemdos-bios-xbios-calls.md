# GEMDOS/BIOS/XBIOS Call Recognition

TOS splits its system API into three layers, each reached through its own
`TRAP` vector. Recognizing the pattern — and knowing where to look up what
a given call number means — is the Atari-side equivalent of recognizing an
unnamed `jsr -552(a6)` as an LVO call on Amiga
(`02-retro-amiga/03-exec-library-kickstart.md`).

## The three APIs and their TRAP numbers

| API | TRAP | Vector | Handler address | Layer |
|---|---|---|---|---|
| GEMDOS | `TRAP #1` | `0x21` | `$84` | filesystem, process, memory management |
| BIOS | `TRAP #13` | `0x2D` | `$B4` | low-level device I/O |
| XBIOS | `TRAP #14` | `0x2E` | `$B8` | extended/hardware-specific (video, sound, MFP, ...) |

Confirmed two independent ways against the Atari Compendium (the
Atari-world equivalent of the Amiga module's RKM/AHRM references — see
`RESEARCH-NOTES.md` for the full citation and its distribution caveat):
each API's own "Function Calling Procedure" section states its TRAP number
explicitly, and the Compendium's separate hardware/vector-table appendix
lists the same three vectors independently. The handler addresses follow
plain 68000 vector-table arithmetic (vector *N* lives at `N × 4`; `TRAP #n`
maps to vector `32 + n` — see the Amiga recap's TRAP/vector-table
citation): vector `33 → 0x84`, `45 → 0xB4`, `46 → 0xB8`, matching TRAP
#1/#13/#14 respectively.

## Calling convention (same shape across all three)

Arguments are pushed onto the stack **in reverse order**, then the 16-bit
function number is pushed last with `move.w #<opcode>,-(sp)`, then the
`TRAP #n` itself. General shape, N arguments already on top of stack:

```
; ... push argument N ... push argument 1 (reverse order) ...
move.w #<opcode>,-(sp)   ; push the function number
trap   #1                 ; GEMDOS (or #13 BIOS / #14 XBIOS)
lea    <argbytes+2>(sp),sp  ; caller cleans up: all arg bytes + 2-byte opcode
```

`Mshrink()` (GEMDOS opcode `0x4A`, called in the previous guide's
stack-shrink note) and `Pexec()` (opcode `0x4B`, "execute another process")
follow exactly this shape — look for the `move.w #$4A,...`/`#$4B,...` +
`trap #1` pair to recognize them by eye.

The **caller** cleans the stack afterward — none of the three APIs pop
their own arguments. All three are free to clobber `D0`–`D2` and `A0`–`A2`
as scratch, and may overwrite the pushed opcode word itself, so don't
expect it to still be there after the call returns.

## How this looks in Ghidra

`TRAP #1` / `TRAP #13` / `TRAP #14` are ordinary, fully-defined 68000
opcodes — Ghidra disassembles them natively with no gaps, same as any other
TRAP. What Ghidra has **no built-in knowledge of** is which function a
given call invokes: the function number is just a plain 16-bit immediate
operand on the `move.w` instruction immediately before the trap, and stock
Ghidra doesn't map, say, `$4B` to `Pexec()`. This is the direct structural
analogue of the Amiga module's unnamed-LVO problem — an opcode Ghidra
disassembles correctly but can't *name* without an external lookup table.

Confirmed from the tooling side too: the community project
`czietz/ghidraScripts_for_Atari` (Ghidra helper scripts for Atari binaries)
lists "a script to annotate TRAPs (OS calls) according to function number"
under its own "ideas for future development" — i.e. as of that project's
current state, this annotation still doesn't happen automatically. Pattern
to look for by eye in the meantime: a `move.w #<imm>,-(sp)` immediately
followed by `trap #1`/`#13`/`#14`, with the immediate as the call number.

## Where to look up call numbers

The Atari Compendium's Book 2 (GEMDOS), Book 3 (BIOS), and Book 4 (XBIOS)
each carry a full per-function reference (name, decimal+hex opcode,
parameters, availability by GEMDOS/TOS version) plus a consolidated
opcode-to-function index — e.g. GEMDOS opcode `0x4B` (decimal 75) is
`Pexec()`, "execute another process." The Compendium itself carries a
"not for public distribution" notice on its title page (an author
draft-review copy from 1992, openly mirrored across the Atari community for
decades but never formally re-released — see `RESEARCH-NOTES.md` §5) — for
a citable, actively-maintained, openly-hosted equivalent, prefer
[FreeMiNT's `tos.hyp`](https://freemint.github.io/tos.hyp/) for the same
API documentation.

Once you've got a name and an opcode, applying it manually in Ghidra is
either a plate comment on the `TRAP` instruction or, at the point this
course's automation module (`05-automation-scripting`) becomes relevant, a
script similar in spirit to the Amiga module's NDK-`.fd` import — matching
each `move.w #imm,-(sp)`/`trap #n` pair against the relevant book's table
and labeling it.

---

**Self-check:** you see `move.w #$3E,-(sp)` immediately followed by
`trap #14` — which API is this, and what's your next step to find out what
function `$3E` is? → XBIOS (`TRAP #14`); look up opcode `0x3E` (62
decimal) in the Atari Compendium's Book 4 opcode index (or the equivalent
`tos.hyp` XBIOS function list) to get the function name and parameters —
Ghidra won't resolve it for you.
