# Exercise: PRG/TOS Executable Format

Covers
[`03-prg-tos-executable-format.md`](../../03-prg-tos-executable-format.md).
Uses the real PRG build of the shared [`sample/`](../sample/) program —
build it first if you haven't for exercise 01:

```sh
cd sample
./build.sh
```

This exercise doesn't touch Ghidra at all — Ghidra has no native PRG/TOS
loader (see the guide), so the only way to actually see the header structure
is to read the raw bytes yourself, the way a loader would have to. (Same
approach `02-retro-amiga`'s Hunk-format exercise took for the same reason.)

## Tasks

1. Dump the header: `od -A x -t x1 sample/sample.prg | head -2`. Confirm the
   first two bytes are `60 1a` — the `PRG_magic` value from the guide,
   read as a big-endian word.
2. Read off the 4 bytes at file offset `0x02` (`PRG_tsize`) as a big-endian
   longword. Compare that value against the byte size of `sample/sample.bin`
   (`ls -l sample/sample.bin` or `wc -c`). They should match exactly — why?
   (Think about what `sample.s` does and doesn't contain.)
3. Read off `PRG_dsize` (offset `0x06`) and `PRG_bsize` (offset `0x0A`).
   `sample.s` has no `data`/`bss` sections at all — confirm both fields read
   as `0`.
4. Read the `ABSFLAG` word at offset `0x1A`. Whatever value you find there,
   what does the guide say you should check *regardless*, and why can't you
   trust `ABSFLAG` alone?
5. Using your `PRG_tsize`/`PRG_dsize`/`PRG_ssize` values from tasks 2–3 (and
   `PRG_ssize` should also read `0` — the build uses `-nosym`), compute the
   fixup-offset field's file position and read the LONG stored there. Given
   that `sample.s` never takes an absolute cross-section reference (unlike
   `02-retro-amiga`'s sample, which needed one for `libname`), what value do
   you expect, and does your dump confirm it?
6. Compare the bytes at file offset `0x1C` in `sample.prg` against the first
   bytes of `sample.bin`. They should be identical — explain why, tying it
   back to where the guide says the TEXT segment always starts.

**Check yourself:** if a colleague's PRG has `PRG_ssize` reading nonzero,
does that tell you anything about whether the file has an embedded symbol
table you personally know how to parse?
