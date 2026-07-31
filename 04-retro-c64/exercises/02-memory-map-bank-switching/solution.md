# Solution: Memory Map & Bank Switching

1. `$36` = `%00110110`. Bit 0 (`LORAM`) = `0`, bit 1 (`HIRAM`) = `1`, bit 2
   (`CHAREN`) = `1`.
2. Selecting `LORAM=0 HIRAM=1 CHAREN=1` in the explorer shows `$A000`-
   `$BFFF` as **RAM**. That *is* different from the power-up default
   (`LORAM=HIRAM=CHAREN=1`), where `$A000`-`$BFFF` is BASIC interpreter ROM
   -- this write specifically banks BASIC ROM out.
3. `$E000`-`$FFFF` still shows **KERNAL ROM** for this bit pattern, because
   `HIRAM=1`. That's exactly why the sample uses `$36` and not, say, `$34`
   (`HIRAM=0`): if `HIRAM` had been `0`, the mode table's row 3 (`1,0,1` or
   here `0,0,X`/`0,0,1` depending on `LORAM`) shows `$E000`-`$FFFF` as plain
   RAM -- the following `jsr $ffd2` would jump into whatever happened to be
   sitting in RAM at that address, not into the real `CHROUT` routine,
   silently breaking the call.
4. `LORAM=0, HIRAM=0` (row 4 of the table; `CHAREN` doesn't matter for this
   row) is the only mode where `$D000`-`$DFFF` reads as RAM instead of I/O
   or Character ROM.
5. A **cartridge** plugged into the expansion port -- specifically its
   `GAME`/`EXROM` lines, which the condensed table assumes are both high
   (`1`, i.e. "no cartridge"). A cartridge can drive those lines low and put
   its own ROM at `$8000`-`$9FFF` regardless of the `$01` register's
   software-controlled bits; the explorer's mode selector deliberately only
   covers the no-cartridge case the guide's condensed table documents.

**Check yourself -- answer:** `$35` = `%00110101` -- `LORAM=1, HIRAM=0,
CHAREN=1`. Per the table, that's row 3: `$A000`-`$BFFF` is **RAM**, not
BASIC ROM (both `LORAM` *and* `HIRAM` need to be `1` together for BASIC ROM
to appear there -- `LORAM=1` alone isn't enough, which is easy to get wrong
by assuming each bit acts independently). To be sure this is really what's
active at the point of the read, you'd need to trace backwards through the
function (and anything it calls) for any earlier `sta $01` -- since
Ghidra's Listing shows one fixed disassembly regardless of runtime bank
state, an earlier write elsewhere in the control flow can silently change
what a later, textually-distant read actually resolves to.
