# Exercise: Custom Chip Registers (Agnus/Denise/Paula)

Covers
[`04-custom-chip-registers.md`](../../04-custom-chip-registers.md). Uses
the shared [`sample/`](../sample/) program (raw-binary import, same as
exercises 01 and 03).

## Tasks

1. In the Listing, find the `lea $dff000,a0` instruction and the three
   `move.w` instructions right after it. Each writes through `a0` with a
   small displacement. Read off the three displacements.
2. Using the register table in the guide, name the register at each
   displacement, and say which chip(s) own it.
3. One of the three writes (`$8200` to `DMACON`) sets bit 9 (`$0200`,
   `DMAEN` — master DMA enable) alongside bit 15 (`$8000`, the register's
   `SET/CLR` control bit — see task 4). Cross-check `DMACON` against the
   fact that it's a **write** register with a **separate read address**.
   What's the read-side register's name and offset, and what would you
   expect to find if this same program later *read* the current DMA state
   instead of only setting it?
4. This exercise's binary never reads any chip register, only writes. Is
   that on its own suspicious/incomplete, or a normal thing to see in
   real Amiga code? Justify from what you know about `DMACON`/`INTENA`'s
   write-only design (clear/set semantics) versus genuinely bidirectional
   registers.

**Check yourself:** if you saw a `move.w #$c020,(a0)` targeting offset
`$09a` (`INTENA`) elsewhere in a disassembly, and `a0` still held
`$dff000`, what would the top two bits (`$c0` = `1100 0000`) of that write
typically mean for a clear/set-style hardware register like this one, even
without a memorized bit table?
