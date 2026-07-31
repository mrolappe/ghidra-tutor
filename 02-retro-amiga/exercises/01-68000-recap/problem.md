# Exercise: 68000 Recap

Covers [`01-68000-recap.md`](../../01-68000-recap.md). Uses the shared
[`sample/`](../sample/) program — the same import used by this whole
module's exercises 01, 03 and 04.

## Build & import

```sh
cd sample
./build.sh
```

Import `sample/sample.bin` as **Raw Binary** (`File → Import File`, pick the
`68000` language/`default` compiler spec — no Hunk loader needed for this
exercise) and auto-analyze. Keep this project around for exercises 03 and
04.

## Tasks

1. Find `start`'s first two instructions in the Listing. One is a `movem.l`
   with a register list, the other a `link`. Write down, in plain English,
   what each one does to `A7` — don't just name the mnemonic, trace the
   stack-pointer effect.
2. Look at how Ghidra prints the `movem.l` register list. `sample.s` wrote
   it as the range `d2-d4/a2-a3`. Does the Listing show that same range
   syntax, or something else? What does this tell you about reading MOVEM
   operands in *other* people's disassembly, where you don't have the
   original source to compare against?
3. Four instructions near the end of the function each use a different
   68000 addressing mode: `move.l (a5),d1`, `move.l 8(a5),d2`,
   `move.l 0(a5,d0.w),d3`, `move.l #$1234,d4`. Name the addressing mode of
   each one's source operand.
4. Find the function's matching `unlk`/`movem.l (a7)+,...` pair right before
   `rts`. Confirm they're the exact mirror image of the `link`/`movem.l
   -(a7)` pair from task 1 — same registers, opposite order, opposite
   pre/post-increment direction.
5. This binary is big-endian, 68000 is big-endian by design — pick any
   4-byte immediate or address in the Listing (e.g. the `#$1234` from task
   3, or an address literal) and check its raw bytes in Ghidra's byte view.
   Confirm the most-significant byte comes first in memory.

**Check yourself:** if you saw `link a5,#-8` and `unlk a5` in a function
*without* a `movem.l` pair around them, would that still be a valid
callee-saved-register convention, or is the `movem.l` doing something
`link`/`unlk` can't?
