# Exercise: Memory Map & Bank Switching

Covers [`02-memory-map-bank-switching.md`](../../02-memory-map-bank-switching.md).
Uses the shared [`sample/`](../sample/) program (same import as exercise 01)
and the module's
[`memory-map-explorer.html`](../../memory-map-explorer.html).

## Tasks

1. In the Listing, find the two instructions `lda #$36` / `sta $01`. Break
   `$36` down into binary and read off `LORAM`, `HIRAM`, and `CHAREN`
   (bits 0-2).
2. Open `memory-map-explorer.html` and select the mode matching task 1's
   bit values. According to the explorer (and the guide's mode table),
   what's banked in at `$A000`-`$BFFF` right after this write executes --
   and is it different from the power-up default (mode with
   `LORAM=HIRAM=CHAREN=1`)?
3. Still using task 1's bit values: what's banked in at `$E000`-`$FFFF`?
   The very next instructions in `sample.s` are `lda #$0d` / `jsr $ffd2`
   (a KERNAL call, see exercise 03). Explain why this specific bit pattern
   was chosen for the sample -- what would break about that `jsr` if
   `HIRAM` had been `0` instead of `1`?
4. Using the explorer, find the *one* mode (of the 7 in the table) where
   `$D000`-`$DFFF` is genuinely RAM rather than I/O or Character ROM. Give
   its `LORAM`/`HIRAM`/`CHAREN` values.
5. Per the guide, `$8000`-`$9FFF` doesn't change across any row of the
   condensed mode table -- what's the one thing (not modeled by the
   explorer's selector) that *can* still put something other than RAM
   there?

**Check yourself:** a colleague's disassembly shows `lda #$35` / `sta $01`
immediately followed by code that reads from `$A000`. Using the explorer or
the guide's table, is that read hitting BASIC ROM or RAM -- and what would
you need to check in the surrounding code to be sure no *earlier* write to
`$01` changed the picture first?
