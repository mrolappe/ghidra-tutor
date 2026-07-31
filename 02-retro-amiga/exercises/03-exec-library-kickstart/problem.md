# Exercise: exec.library & Kickstart Basics

Covers [`03-exec-library-kickstart.md`](../../03-exec-library-kickstart.md).
Uses the shared [`sample/`](../sample/) program, both builds.

## Part A — recognize the pattern without a loader

Import `sample/sample.bin` as **Raw Binary** (same as exercise 01) if you
don't already have that project open, and auto-analyze.

1. Find the three-instruction sequence: `move.l 4.w,a6`, then a `lea`/`moveq`
   pair loading `a1`/`d0`, then `jsr -552(a6)`. Without any symbol names
   present, explain in your own words what each of the three instructions
   is doing and why `-552` specifically is meaningful (see the guide).
2. Right-click the `-552` operand and add an EOL comment naming what this
   call is (`OpenLibrary`, per the guide) and what library name is being
   passed (look at what `a1` was loaded with — follow the `lea` operand's
   reference into the data hunk's string).
3. This required you to already know the LVO table from the guide. What
   specifically about the raw disassembly — with zero comments, zero
   symbols — told you this *might* be a library call worth checking,
   before you looked anything up? (Hint: which register, which kind of
   constant.)

## Part B — optional: see it loader-resolved

The [Hunk format guide](../../02-hunk-executable-format.md) names
[`BartmanAbyss/ghidra-amiga`](https://github.com/BartmanAbyss/ghidra-amiga)
as the practical way to import a real Hunk executable with library symbols
resolved automatically, instead of doing Part A's manual recognition by
hand. If you want to try it:

4. Install the extension (`File → Install Extensions` in Ghidra, or drop
   its release zip into `<ghidra-install>/Extensions/Ghidra/` and restart).
   **Version note**: its releases are built against specific Ghidra point
   releases (the most recent as of this writing targets Ghidra 12.0.1, not
   this course's pinned 12.1.2) — if the prebuilt zip doesn't load, you'll
   need to build it from source against your installed Ghidra version
   (it's a normal Gradle-based Ghidra extension) rather than assume the
   prebuilt release is a drop-in match.
5. Import `sample/sample.hunk` with the extension active and let it
   auto-analyze. Find the same `jsr` call from task 1 — does it now show a
   resolved name like `_LVOOpenLibrary` instead of a bare `-552(A6)`
   offset? If your `sample.hunk` build didn't include NDK symbol data (it
   won't, since `sample.s` never referenced Amiga includes), you may still
   see the raw offset — in which case, what does that tell you about what
   the extension actually needs in order to resolve LVO names (the loader
   itself, vs. imported `.fd`/NDK symbol data)?

**Check yourself:** if Part A's manual recognition and Part B's
loader-resolved import disagree about *which* library function `-552`
maps to, which one would you trust, and why?
