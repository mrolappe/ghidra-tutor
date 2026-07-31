# Solution: Amiga Hunk Executable Format

1. See the table in the problem — `od -A d -t x4 sample/sample.hunk` gives
   you the raw longwords to scan for those hex values.
2. Expected sequence: `HUNK_HEADER` → `HUNK_CODE` → `HUNK_RELOC32` →
   `HUNK_END` → `HUNK_DATA` → `HUNK_END` (no second `HUNK_RELOC32` — the
   data hunk only holds the `libname` string, nothing in it needs
   relocating). Compared to the README's diagram, everything through the
   data hunk matches; the trailing `HUNK_BSS`/`HUNK_END` pair is missing
   because `sample.s` declares no uninitialized (BSS) storage at all — a
   program is allowed to have zero BSS hunks, so this is a normal, complete
   two-hunk executable, not a truncated one.
3. The code hunk's `HUNK_RELOC32` block contains one relocation entry,
   targeting the offset of the `lea libname.l,a1` instruction's address
   field, pointing at hunk 1 (the data hunk). This is exactly what lets
   `libname`'s *runtime* address be patched in at load time — the code
   hunk and data hunk can each be loaded at whatever free memory address
   AmigaDOS finds, in either order, and the loader adds the data hunk's
   actual load address into that one longword before execution starts. A
   hard-coded absolute address in the code would only be correct if the
   data hunk always loaded at one fixed, predictable address, which the
   Amiga's dynamic loader doesn't guarantee.
4. The code hunk's size longword in `HUNK_HEADER` should show `0` in both
   of its top two bits (i.e. the top byte/nibble reads as a small value
   with the high bits clear) — this program never asks for Chip-RAM-only
   or Fast-RAM-only placement, so neither attribute flag is set, and the
   loader is free to put it anywhere.

**Check yourself — answer:** no — per the guide, `HUNK_BSS` is just a
zeroed, uninitialized region with nothing stored in the file to relocate.
A bare size-and-`HUNK_END` is the complete, normal shape for a BSS hunk;
seeing that pattern is not evidence of truncation on its own.
