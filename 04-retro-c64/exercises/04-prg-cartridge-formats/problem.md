# Exercise: PRG & Cartridge (CRT) Formats

Covers
[`04-prg-cartridge-formats.md`](../../04-prg-cartridge-formats.md). Uses the
real PRG build of the shared [`sample/`](../sample/) program -- build it
first if you haven't for exercise 01:

```sh
cd sample
./build.sh
```

Part A doesn't touch Ghidra at all -- there's no native or reliably-
installable PRG loader (see the guide), so the only way to actually see the
header structure is to read the raw bytes yourself, the way a loader would
have to (same approach the Amiga module took for Hunk blocks, and the Atari
ST module took for the PRG/TOS header). Part B works from the guide's own
cited VICE-manual example instead of a built file, since building a real
cartridge image is out of scope for a homebrew toolchain exercise.

## Part A -- PRG header (your own build)

1. Dump the first 16 bytes: `od -A x -t x1 sample/sample.prg | head -1`.
   Confirm the first two bytes, read little-endian, give the load address
   `$0801` -- matching `c64-asm.cfg`'s documented default start address
   (see `build.sh`'s comment).
2. `build.sh` links in `__EXEHDR__`, so the bytes starting right after that
   2-byte header (i.e. at file offset `0x02`, corresponding to memory
   address `$0801`) should be a **tokenized BASIC line**, not 6502 code yet.
   Per the guide's cited BASIC-token format: the first 2 bytes are a
   "next line" link-address pointer (little-endian), the next 2 are the
   line number (little-endian), and after that comes a **token byte**
   marking a BASIC keyword. Read off all 5 of these values from your dump.
3. `$9E` is the token for `SYS`. Confirm the byte you read in task 2 is
   `$9E`, then read the bytes immediately following it as PETSCII/ASCII
   text up to the next `$00`. What SYS target address does this spell out
   (as a plain decimal number)?
4. Convert that decimal SYS target from task 3 to hex, and dump the file
   at that exact memory address (remember: file offset = memory address
   minus `$0801`, plus the 2-byte load-address prefix, i.e.
   `file_offset = (address - 0x0801) + 2`). Do the bytes there match the
   very first instruction of `sample.s` (`lda #$05` -> opcode bytes
   `A9 05`)?
5. The task-2 link-address pointer should equal the address of the BASIC
   line's own end-of-program marker (two `$00` bytes, right after a single
   `$00` end-of-line byte). Confirm this against your dump, and explain
   why a *shorter* line number or SYS target (e.g. one fewer digit) would
   shift this pointer's value.

## Part B -- CRT header (worked from the guide's cited example, no build)

The guide's CRT tables are read directly off VICE's own documented example
dump for an 8K "Attack Of The Mutant Camels" cartridge: signature
`"C64 CARTRIDGE  "`, header length `$00000040`, `EXROM=$00`, `GAME=$01`,
followed (after the 64-byte file header) by one `CHIP` packet with chip
type `0` (ROM), load address `$8000`, and ROM image size `$2000`.

6. Using the header-length field (`$40` = 64 bytes) and the `CHIP` packet's
   own header being 16 bytes (`+$00`..`+$0F`, per the guide's packet table)
   plus its `$2000`-byte ROM payload, compute this cartridge file's total
   size in bytes.
7. Per the guide, a "generic" (type-0) cartridge's `ROML` always loads at
   `$8000`. Using `EXROM=$00`/`GAME=$01` from this example and the fact
   that this is an 8K image (fits entirely in `$8000`-`$9FFF`), would you
   expect a second `CHIP` packet for `ROMH` in this specific file? Why or
   why not?
8. Cross-reference this cartridge's load address (`$8000`) against
   [`02-memory-map-bank-switching.md`](../../02-memory-map-bank-switching.md)'s
   memory map: which address range does that guide say is normally "free
   BASIC/ML storage" but becomes cartridge ROM here instead -- and why
   doesn't that guide's condensed 7-row mode table cover this case at all?

**Check yourself:** if a `.CRT` file's header-length field read `$00000020`
instead of `$00000040`, would that automatically mean the file is
malformed, given what the guide says `$40` represents?
