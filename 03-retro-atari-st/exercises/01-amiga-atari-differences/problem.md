# Exercise: 68000/TOS Differences From Amiga

Covers [`01-amiga-atari-differences.md`](../../01-amiga-atari-differences.md).
Uses the shared [`sample/`](../sample/) program — the same import used by
this whole module's exercises 01 and 02.

## Build & import

```sh
cd sample
./build.sh
```

Import `sample/sample.bin` as **Raw Binary** (`File → Import File`, pick the
`68000` language/`default` compiler spec — no PRG loader needed for this
exercise) and auto-analyze. Keep this project around for exercise 02.

## Tasks

1. Find `start`'s first instruction. It reads a longword from `4(sp)` into
   `A0`. What does this value represent on TOS, and why is there no
   Amiga-style fixed absolute address you could've scanned for instead?
2. The next two instructions read `$0c(a0)` and `$18(a0)`. Using the
   basepage field table in the guide, name both fields and what each one
   means.
3. Right after the basepage reads, find a `move.w #$4A,-(sp)` /
   `trap #1` pair. Per the guide, what GEMDOS call is this, and why does it
   make sense for it to show up this early — right after a program has just
   looked at its own TPA bounds?
4. Later in the function, find a second `move.w #imm,-(sp)` / `trap #1`
   pair, with a different immediate. Name the call and explain the specific
   RE signal the guide attaches to it — what should you now expect the
   surrounding code to be about to do?
5. Suppose you were handed an Amiga Hunk binary instead and asked to find
   "the equivalent of task 1's read." What would you scan for there, and
   why is it a fundamentally different *kind* of pattern (fixed address vs.
   per-process handoff) rather than just a different address?

**Check yourself:** you're handed a raw 68000 binary with no header, no
symbols, and told only "it's either an Amiga or an Atari ST program." What's
the single fastest instruction-level check near the entry point that would
tell you which?
