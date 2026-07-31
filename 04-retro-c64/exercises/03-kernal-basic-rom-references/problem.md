# Exercise: KERNAL/BASIC-ROM References in Disassembly

Covers
[`03-kernal-basic-rom-references.md`](../../03-kernal-basic-rom-references.md).
Uses the shared [`sample/`](../sample/) program (same import as exercises 01
and 02).

## Tasks

1. Find the `jsr $ffd2` in the Listing. Ghidra gives you no symbol here --
   using the guide's jump-table, which KERNAL routine is this, and what
   does it do?
2. The instruction right before it is `lda #$0d`. Combine that with task 1
   to describe, in one sentence, what this pair of instructions actually
   does when executed.
3. Per the guide, the KERNAL jump table occupies a fixed 115-byte window.
   State its start and end addresses, and explain why a `jsr`/`jmp` target
   landing anywhere in that window can be identified as a KERNAL call with
   no other information needed.
4. Manually create a label named `CHROUT` at `$FFD2` in your Ghidra project
   (right-click the address in the Listing → rename, or use the Symbol
   Tree). Re-examine `jsr $ffd2` -- how does the instruction display
   differently now, and why is this exactly the same payoff
   [Function ID](../../../01-core-workflows/04-function-id-fid.md) gives for
   recurring *library* code, applied here to a fixed *jump table* instead?
5. Nothing in `sample.s` calls into `$A000`-`$BFFF` (BASIC ROM). Per the
   guide, what's the one common, recognizable way a real C64 program
   *does* end up jumping into that range from hand-written machine code,
   and which other guide covers the file-format side of that pattern?

**Check yourself:** you're looking at a disassembly with no debug symbols
and see `jsr $ffe4` immediately followed by a branch on whether the
accumulator is zero. Without consulting the table again, can you reason out
roughly what this code is doing structurally, and what a zero result from
this particular KERNAL call would mean in context?
