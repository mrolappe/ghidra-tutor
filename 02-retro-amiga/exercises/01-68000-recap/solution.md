# Solution: 68000 Recap

1. `movem.l d2-d4/a2-a3,-(a7)`: predecrement, so before each register is
   stored `A7` is decremented by 4 — five registers (`D2 D3 D4 A2 A3`) means
   `A7` ends up 20 bytes lower, holding all five saved values.
   `link a5,#-8`: pushes the current `A5` (another 4 bytes off `A7`), then
   sets `A5 = A7` (new frame pointer), then `A7 -= 8` to reserve locals — a
   further 8-byte drop. Net effect of both instructions together: `A7` is
   24 bytes lower than at function entry.
2. Ghidra shows `D2 D3 D4 A2 A3` — individual, space-separated names, not
   the `d2-d4/a2-a3` range syntax the source used. Lesson: range syntax is
   purely an assembler-source convenience; by the time you're reading
   disassembly (yours or someone else's) it's already gone, so don't expect
   to see it and don't read anything into its absence.
3. `(a5)` → Register Indirect. `8(a5)` → Register Indirect with
   Displacement. `0(a5,d0.w)` → Address Register Indirect with Index,
   8-bit Displacement (displacement happens to be 0 here, but the mode is
   the same). `#$1234` → Immediate.
4. `unlk a5` reverses `link a5,#-8` exactly (`A7 = A5`, then pop the saved
   `A5` back). `movem.l (a7)+,d2-d4/a2-a3` reverses the entry `movem.l` —
   same register list, postincrement instead of predecrement, so it pops in
   the same order the entry instruction pushed. Confirms the standard
   save-on-entry/restore-on-exit bracket.
5. A 4-byte value like `#$1234` (stored as `00 00 12 34`) or any absolute
   address literal shows its most-significant byte first in the byte view —
   confirming big-endian layout, the opposite of what you'd see reading x86
   dumps.

**Check yourself — answer:** yes, still a valid convention, just a narrower
one — `link`/`unlk` only ever save/restore the frame-pointer register
itself (`A5` here) as a side effect of setting up the frame; they can't
touch an arbitrary register list. Saving `D2–D4`/`A2–A3` specifically is
`movem`'s job, and a function that modifies those registers without an
accompanying `movem` pair would be corrupting its caller's register state —
`link`/`unlk` alone doesn't cover that.
