# Exercise: VIC-II & SID Registers

Covers [`05-vic-sid-registers.md`](../../05-vic-sid-registers.md). Uses the
shared [`sample/`](../sample/) program (same import as exercises 01-03).

## Tasks

1. Find the `sta $d020` in the Listing. Using the guide's VIC-II table,
   name this register and what it controls.
2. Find the three writes to `$d400`, `$d401`, and `$d404`. Using the SID
   table, name all three registers and which SID voice they belong to.
3. `sample.s` writes `$d400`/`$d401` (frequency low/high) *before*
   `$d404` (the control register) -- not the other way around. Per the
   guide's "recognition shortcut," why does this ordering matter for
   recognizing "this is initializing one sound" versus "this is just
   scattered pokes"?
4. The value written to `$d404` is `$11` (`%00010001`). Per the guide's bit
   layout for a voice's control register, which waveform does bit pattern
   `0001` (bits 4-7) select, and what does bit 0 being set (`GATE=1`) do?
5. Neither `$d020` nor any of the three SID writes go through a KERNAL
   call (contrast with exercise 03's `jsr $ffd2`). What's the one
   structural fact about raw `$d0xx`/`$d4xx` addresses -- true on this
   platform the same way raw `$dff0xx` addresses were on Amiga -- that
   makes this distinction ("hardware-banging code" vs. an OS call)
   immediately visible just from the operand, with no symbol needed?

**Check yourself:** if you saw a write to `$D015` (`MxE`, sprite enable
bits) with no other VIC-II or SID writes anywhere nearby in the function,
would you expect graphics or sound to be affected, and specifically what
kind of change?
