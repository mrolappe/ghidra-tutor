# Exercise: GEMDOS/BIOS/XBIOS Call Recognition

Covers [`02-gemdos-bios-xbios-calls.md`](../../02-gemdos-bios-xbios-calls.md).
Reuses the same imported `sample/sample.bin` project from exercise 01 — the
`Mshrink()`/`Super()` pair you already found there is this exercise's
starting point.

## Tasks

1. For both TRAP pairs you found in exercise 01 (tasks 3 and 4), name the
   TRAP number and which of the three APIs (GEMDOS/BIOS/XBIOS) it belongs
   to. Is there any ambiguity, or does the TRAP number alone settle it?
2. Neither call in `sample.s` pushes any argument longwords/words before the
   opcode `move.w` — just the bare opcode-then-`trap` pair. Does this
   contradict the general calling-convention shape from the guide (args
   pushed in reverse order, then the opcode, then the trap)? Why or why not?
3. In Ghidra, add an EOL comment on each of the two `trap #1` instructions
   in your imported binary naming the call (`Mshrink`/`Super`) and its
   opcode in hex.
4. You come across `move.w #$3E,-(sp)` immediately followed by `trap #14`
   in a *different* binary (not this module's sample). Which API is this,
   and where would you go to find out what function `$3E` actually is,
   given that Ghidra won't resolve or name it for you?
5. The guide says stock Ghidra 12.1.2 has no built-in TRAP-opcode-to-name
   database for any of the three APIs. Name the one community tool this
   module's guides mention that has "annotate TRAPs according to function
   number" listed as a *future* idea — i.e. confirm this gap isn't closed
   yet even by that project's current state.

**Check yourself:** why is the TRAP number alone (`#1` vs `#13` vs `#14`)
never enough, by itself, to tell you which specific *function* is being
called?
