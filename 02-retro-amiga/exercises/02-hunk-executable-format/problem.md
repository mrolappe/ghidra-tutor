# Exercise: Amiga Hunk Executable Format

Covers [`02-hunk-executable-format.md`](../../02-hunk-executable-format.md).
Uses the Hunk-linked build of the shared [`sample/`](../sample/) program —
build it first if you haven't for exercise 01:

```sh
cd sample
./build.sh
```

This exercise doesn't touch Ghidra at all — Ghidra has no native Hunk
loader (see the guide), so the only way to actually see the block structure
is to read the raw bytes yourself, the way a loader would have to.

## Tasks

1. Dump `sample/sample.hunk` as 32-bit big-endian words:
   `od -A d -t x4 sample.hunk | less` (or any hex viewer that groups 4
   bytes at a time). Every Hunk block starts with one such longword giving
   its type ID. Use this ID → hex table (from `doshunks.h`, values below
   1000000000 decimal shown as their big-endian hex encoding) to find each
   block type's opening longword in the dump:

   | Block | ID (dec) | ID (hex, as it appears in the dump) |
   |---|---|---|
   | `HUNK_CODE` | 1001 | `000003e9` |
   | `HUNK_DATA` | 1002 | `000003ea` |
   | `HUNK_RELOC32` | 1004 | `000003ec` |
   | `HUNK_END` | 1010 | `000003f2` |
   | `HUNK_HEADER` | 1011 | `000003f3` |

2. Walk the file from offset 0 and write down the sequence of block IDs you
   find, in order. Compare it against the module README's Mermaid diagram —
   which blocks from that diagram are present, and which one is missing
   (and why it's fine that it's missing — check the guide if you're not
   sure)?
3. `sample.s` has code that references `libname` (a string living in the
   `data` section) using `lea libname.l,a1` — an absolute, not PC-relative,
   reference (see the comment in `sample.s` explaining why). Find the
   `HUNK_RELOC32` block for the code hunk and confirm it contains at least
   one relocation entry. What does that entry let the Amiga loader do that
   a hard-coded absolute address baked into the code couldn't?
4. `HUNK_HEADER`'s per-hunk size longwords double as memory-attribute
   flags in their top two bits. Find the size longword for the code hunk in
   your dump and confirm its top two bits are both `0` (no Chip/Fast RAM
   requirement) — this program doesn't touch anything that needs a specific
   RAM type.

**Check yourself:** if you `od`'d a *different* Amiga executable and found
a `HUNK_BSS` block immediately followed by `HUNK_END`, with no
`HUNK_RELOC32` between them, would you suspect the file is truncated?
