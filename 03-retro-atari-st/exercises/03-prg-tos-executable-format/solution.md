# Solution: PRG/TOS Executable Format

1. `od -A x -t x1 sample/sample.prg | head -2` should show `60 1a` as the
   first two bytes — the fixed `PRG_magic` value every GEMDOS loader checks
   before treating a file as a valid PRG.
2. `PRG_tsize` should equal `sample.bin`'s exact byte size. This is because
   `sample.s` contains only a `text` section — no `data`, no `bss` — so the
   TEXT segment *is* the program, and a flat `-Fbin` dump of that same
   source necessarily produces exactly `PRG_tsize` bytes with nothing
   before or after it.
3. Both should read as all-zero longwords (`00 00 00 00`) — there is
   nothing in `sample.s` for either segment to hold.
4. Per the guide, `ABSFLAG` is unreliable on some TOS versions when
   non-zero, so regardless of what value you actually see, you should still
   check the fixup-offset field (task 5) directly rather than trusting
   `ABSFLAG` alone to tell you whether relocations are present.
5. With `PRG_dsize` and `PRG_ssize` both `0`, the fixup offset field sits at
   `PRG_tsize + 0x1c` and its value should read `0` — no relocations. This
   matches expectations: `sample.s` has exactly one section, so nothing in
   it references another section's address, and there's nothing for a
   relocation entry to patch at load time (contrast with
   `02-retro-amiga`'s sample, whose `lea libname.l,a1` *does* need a
   relocation because it's an absolute cross-hunk reference).
6. They should match byte-for-byte. Per the guide, there's no separate
   entry-point field in the PRG header at all — the loader always jumps to
   byte 0 of the TEXT segment, which always starts at fixed file offset
   `0x1C` regardless of segment sizes; since `sample.bin` is nothing but
   that same TEXT segment with no header in front of it, the two byte
   streams are identical from that point on.

**Check yourself — answer:** no, not on its own. `PRG_ssize` only tells you
*how many bytes* the symbol table occupies, not its layout — the guide
notes the format is compiler/vendor-specific, so a nonzero size tells you a
table is present and where it ends (for locating the fixup-offset field
right after it), but reading its actual contents needs separate,
vendor-specific documentation you may or may not have.
