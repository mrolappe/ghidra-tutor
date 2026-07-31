# Solution: PRG & Cartridge (CRT) Formats

## Part A

1. The first two bytes, read little-endian, should give `$0801` -- the
   fixed default start address `c64-asm.cfg` uses, per cc65's own C64
   platform docs.
2. Reading from file offset `0x02` (memory `$0801`): bytes 0-1 are the
   link-address pointer (little-endian word), bytes 2-3 are the line
   number (little-endian word), and byte 4 is the token byte for the
   line's first keyword.
3. That token byte should read `$9E` (`SYS`). The bytes right after it,
   read as PETSCII/ASCII up to the next `$00`, spell out a decimal number
   -- the address `cl65`'s `__EXEHDR__` module computed as this build's
   actual code entry point (this value is determined by the linker at
   build time, so it isn't asserted here as a fixed number -- read it off
   your own dump).
4. Converting that decimal value to hex and computing
   `file_offset = (address - 0x0801) + 2` should land you exactly on bytes
   `A9 05` -- the opcode+operand for `sample.s`'s first instruction,
   `lda #$05`. This confirms the SYS stub's target really is the start of
   your code, not an off-by-one guess.
5. The link pointer (task 2) should equal the address of the two-byte
   end-of-program marker, which sits right after a single end-of-line
   `$00` byte -- i.e. `link_address = $0801 + (bytes from link-pointer-
   start through end-of-line-byte, inclusive)`. A shorter SYS-target
   number (fewer ASCII digits) would shrink the line's total byte count,
   which shifts every following byte -- including the end-of-program
   marker itself -- one position earlier per digit removed. This is also
   why `cl65`'s exehdr module can't just hardcode a number: the header's
   own length depends on how many digits the entry address needs, which in
   turn depends on the header's length -- resolved by the linker computing
   it directly rather than by convention.

## Part B

6. `64` (file header) `+ 16` (`CHIP` packet header) `+ 0x2000` (`8192`,
   ROM payload) `= 8272` bytes total.
7. No second `CHIP` packet for `ROMH` would be expected. The guide
   describes this specific example as an "8K cartridge" -- one `$2000`-byte
   image that fills `$8000`-`$9FFF` (`ROML`) completely, with nothing left
   over for a separate `$A000`- or `$E000`-based `ROMH` image. A 16K
   cartridge (two full `$2000` chips) would be the case that needs both.
8. `$8000`-`$9FFF` is normally listed as "Free BASIC program storage" in
   the RAM view (part of the guide's `$0800`-`$9FFF` row) -- here it holds
   cartridge ROM instead. The condensed 7-row mode table explicitly assumes
   `GAME=EXROM=1` (no cartridge); a real cartridge drives those two lines
   itself (here `EXROM=$00`, `GAME=$01`), which is a different PLA
   configuration entirely, outside that table's documented scope.

**Check yourself -- answer:** yes, reasonably treat it as malformed (or at
least highly suspect) -- the guide states `$40` is the "standard/minimum
value," and the file header's own fixed-position fields (the 32-byte
cartridge-name field alone runs from offset `$0020` to `$003F`) require at
least 64 bytes to exist at all. A header-length of `$20` (32) would be
too short to contain those documented fixed fields, so it isn't just an
unusual-but-legal smaller variant -- it contradicts the format's own fixed
layout.
