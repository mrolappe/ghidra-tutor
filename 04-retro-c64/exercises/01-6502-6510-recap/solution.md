# Solution: 6502/6510 Recap

1. `lda #$05` is **Immediate** (`#$xx`) -- the value `$05` is encoded right
   in the instruction, no memory read needed beyond the opcode+operand
   bytes themselves. `sta $02` is **Zero page** (`$xx`) -- one byte smaller
   than the absolute form (`$xxxx` would need a second address byte the CPU
   doesn't have to fetch or decode), and faster because the 6502 doesn't
   need an extra cycle to process a high address byte that's implicitly
   `$00`.
2. **Zero page,X** (`$xx,X`). With `X` holding `$00` (from `ldx #$00` just
   before), the effective address is `$10 + $00 = $10` -- plain zero page in
   this specific run, but the *addressing mode* is still indexed; a
   different `X` value would move the effective address elsewhere within
   page zero.
3. `lda $0400` is **Absolute**, `lda $0400,x` is **Absolute,X**. Neither
   could be zero-page form: zero-page addressing can only reach `$0000`-
   `$00FF` (one byte's worth of address), and `$0400` is well outside that
   range -- these must be two-byte absolute addresses.
4. Per the guide's "Ghidra has no 6510 variant" section: Ghidra ships only
   `6502:LE:16:default`/`65C02:LE:16:default`, with no special-cased
   `$00`/`$01` I/O-port modeling -- both addresses fall inside the plain,
   auto-created `ZERO_PAGE` block from `6502.pspec` and are treated as
   ordinary RAM. At runtime, though, this write is the 6510's bank-switch
   port register: setting it to `$36` changes which physical
   chip (BASIC ROM vs. RAM at `$A000`-`$BFFF`, in this case) the CPU sees at
   other addresses from this point forward -- something no amount of
   staring at Ghidra's static Listing view alone will show you.
5. Per `6502.pspec`'s `<default_symbols>` block (same source the guide
   cites), Ghidra auto-labels these three vector words `NMI` (`$FFFA`-
   `$FFFB`), `RES` (`$FFFC`-`$FFFD`), and `IRQ` (`$FFFE`-`$FFFF`). `RES` is
   the one that matters here -- it's the reset vector, read by the CPU on
   power-up/reset and loaded into `PC`, marking where execution of a
   freshly loaded, freshly reset chip actually begins (this sample program
   doesn't set up its own reset vector -- it's meant to be read in Ghidra's
   Listing starting at `start`, not actually run).

**Check yourself -- answer:** `$0100` and `$01FF`. `SP` is only an 8-bit
index; the 6502 always combines it with a hard-coded high byte of `$01` to
form the real address, so no value `SP` can ever hold reaches outside page
1 -- there is no way to redirect the stack elsewhere the way a 68000 program
can point any address register at any page of memory.
