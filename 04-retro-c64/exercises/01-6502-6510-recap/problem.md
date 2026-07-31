# Exercise: 6502/6510 Recap

Covers [`01-6502-6510-recap.md`](../../01-6502-6510-recap.md). Uses the
shared [`sample/`](../sample/) program -- the same import used by this
whole module's exercises 01, 02, 03 and 05.

## Build & import

```sh
cd sample
./build.sh
```

Import `sample/sample.prg` into Ghidra: since there's no built-in or
reliably-installable PRG loader (see the guide and
[04-prg-cartridge-formats.md](../../04-prg-cartridge-formats.md)), do it
manually as **Raw Binary** -- read the file's first two bytes as a
little-endian load address, then import the rest of the file starting at
that address, with the `6502:LE:16:default` language (there is no separate
"6510" language ID to pick, per the guide). Auto-analyze. Keep this project
around for exercises 02, 03 and 05.

## Tasks

1. Find `start`'s first instruction, `lda #$05`. Which addressing mode is
   this, per the guide's table? Now find `sta $02` right after it -- name
   this one too, and say in one sentence why it's both smaller *and* faster
   than the equivalent absolute-mode encoding would be.
2. `lda $10,x` uses the same base addressing mode family as `sta $02`, but
   with a `,X` suffix. Name this mode, and explain what value ends up in the
   effective address given that `ldx #$00` ran just before it.
3. Two `lda` instructions target `$0400` -- one plain, one `,x`. Name both
   addressing modes. Given the guide's table, could either of these have
   been assembled in zero-page form instead? Why or why not?
4. This binary's `sta $01` (right after `lda #$36`) looks, in Ghidra's
   Listing, exactly like a write to ordinary zero-page RAM -- no different
   from the `sta $02` in task 1. What fact from the guide explains why
   Ghidra shows no distinction here, and what does that write actually do
   at runtime that Ghidra's static view can't represent?
5. Check the Listing's auto-created symbols at `$FFFA`-`$FFFF`. What are
   they named, and which one marks where execution of a freshly loaded,
   freshly reset 6510 actually begins?

**Check yourself:** if you saw `SP` (the stack pointer) holding `$F0` in a
register-state dump, what two addresses bound the range of memory it could
possibly be pointing into right now, and why can it never point outside
that range on stock 6502/6510 hardware?
