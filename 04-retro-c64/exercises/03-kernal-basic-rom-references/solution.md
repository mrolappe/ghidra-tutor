# Solution: KERNAL/BASIC-ROM References in Disassembly

1. `$FFD2` is `CHROUT` -- "write a character to the output channel."
2. Loading the accumulator with `$0D` (carriage return, PETSCII/ASCII CR)
   and then calling `CHROUT` prints a carriage return to the current output
   channel -- the KERNAL equivalent of `putchar('\n')`.
3. The table runs from `$FF81` (`SCINIT`) to `$FFF3` (`IOBASE`) --
   `$FFF3 - $FF81 + 1 = 115` bytes. Since every entry is a fixed 3-byte
   `JMP` and the table is packed with no gaps, any call target landing
   anywhere inside `$FF81`-`$FFF3` is necessarily hitting one of these 40
   entries -- no other legitimate `jsr`/`jmp` destination lives inside that
   window on any KERNAL revision.
4. After labeling `$FFD2` as `CHROUT`, the Listing shows `jsr CHROUT`
   instead of `jsr $FFD2` -- the call site is now self-documenting without
   needing to re-look-up the address. This is the identical payoff Function
   ID describes for recurring library code (turning an anonymous call into
   a named one), just applied to a *fixed, well-known jump table* instead of
   a *fuzzy-matched, recurring function body* -- the mechanism (attach a
   name once, benefit at every call site) is the same idea in both cases,
   even though how the target gets recognized differs completely.
5. Per the guide, the standard bootstrap is a `.PRG` starting with a short
   tokenized BASIC line that calls `SYS <address>` to jump from "loaded" to
   "running machine code" -- that `SYS` is the thing that actually lands
   execution inside BASIC ROM (to interpret and execute the tokenized
   line) before handing off to the machine code. The file-format side of
   this is covered in
   [`04-prg-cartridge-formats.md`](../../04-prg-cartridge-formats.md).

**Check yourself -- answer:** `$FFE4` is `GETIN` -- "get a character from
the input queue." Structurally, a `jsr $ffe4` immediately followed by a
zero-check is the non-blocking-poll shape: unlike `CHRIN` (which blocks
until a character is available), `GETIN` returns immediately, with `A=0`
conventionally meaning "nothing typed yet" -- so a branch on the
accumulator being zero right after this call is very likely a "check for a
keypress without blocking, then loop or continue" pattern, the same shape
as a non-blocking `getchar()`/input-buffer check on any other platform.
