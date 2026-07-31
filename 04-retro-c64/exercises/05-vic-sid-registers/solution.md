# Solution: VIC-II & SID Registers

1. `$D020` is `EC`, the border color register.
2. `$D400` is voice 1's frequency register (low byte), `$D401` is voice 1's
   frequency register (high byte), and `$D404` is voice 1's control
   register.
3. Per the guide's recognition shortcut, a control-register write
   *immediately preceded by* frequency/pulse-width/ADSR writes to the
   *same voice's* other registers is the tell for "this is initializing one
   sound" -- the control register (which includes `GATE`, the bit that
   actually starts the envelope) is meant to be the last thing written
   once the voice's other parameters are already in place. Writing it
   first, before frequency is set, would start a note with whatever
   frequency happened to be left over from a previous sound -- a real
   program wouldn't do that, which is exactly why the order itself is a
   useful signal.
4. `%00010001`: bits 4-7 = `0001` selects **triangle** (per the guide's
   waveform-select bits), and bit 0 (`GATE=1`) starts the envelope --
   i.e., begins playing the note using whatever attack/decay/sustain/
   release values are set in this voice's ADSR registers.
5. Per the guide, `$D000`-`$D3FF` (VIC-II) and `$D400`-`$D7FF` (SID) are
   raw memory-mapped I/O addresses -- writing to them *is* the hardware
   operation, with no OS routine, jump table, or call convention involved
   at all. This is structurally identical to Amiga's `$dff0xx` custom-chip
   registers: any `sta`/`lda` whose operand falls in one of these ranges
   is unambiguously "poking the chip directly," visible from the raw
   address alone, in contrast to `jsr $ffd2`-style KERNAL calls (exercise
   03), which go through a named entry point instead of touching hardware
   registers directly.

**Check yourself -- answer:** graphics, not sound -- `$D015` is entirely
within the VIC-II block (`$D000`-`$D3FF`), nowhere near SID's `$D400`-
`$D7FF`. Specifically, `MxE` is the sprite-enable bit field (one bit per
hardware sprite, 0-7) -- a write here turns one or more of the eight
sprites on or off, with no effect on sound.
