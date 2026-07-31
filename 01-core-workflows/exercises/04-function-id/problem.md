# Exercise: Function ID

Covers [`04-function-id-fid.md`](../../04-function-id-fid.md). Own sample
pair (not the shared exercise 01–03 program) — see [`sample/`](sample/).

Ghidra ships FID databases only for Microsoft Visual Studio's statically-
linked CRT on x86, so there's nothing installed that would recognize this
module's exercise code. Instead, this exercise has you build a tiny FID
database of your own and confirm it recognizes the same library code inside
a *different* binary — the same mechanism the guide describes, at a scale
you can fully inspect.

## Build

```sh
cd sample
./build.sh
```

Produces `reference.bin` and `target.bin` — both `#include` the same
`lib.c` (two small functions, `checksum` and `clamp`), but each has a
different `main`/driver around it, so the two binaries are **not**
identical overall, even though `checksum`/`clamp` compile to identical
bytes in both.

## Tasks

1. Import and auto-analyze `reference.bin` in a project. Its functions come
   in as `FUN_<addr>` as usual. Read the two non-`main` functions' bodies and
   rename them to their real names, `checksum` and `clamp` — this simulates
   "a program you've already fully analyzed."
2. Enable the Function ID plugin: `File → Configure → Ghidra Core →
   FidPlugin`. Under `Tools → Function ID → Create new empty FidDb...`,
   create a database file **outside** the Ghidra install directory (e.g.
   somewhere in your home folder).
3. `Tools → Function ID → Populate FidDb from programs...` — target your new
   database, give it a Library Family Name (e.g. `my-toy-lib`) and Version
   (e.g. `1.0`), and point the Root Folder at the project folder containing
   your renamed `reference.bin`. Confirm the ingest summary reports 2
   functions processed.
4. Import and auto-analyze `target.bin` as a **separate**, fresh program —
   don't reuse anything from `reference.bin`. Confirm its functions also
   start out as `FUN_<addr>` (it was built and stripped independently).
5. With your new FidDb active (check `Tools → Function ID → Choose active
   FidDbs...`), run Function ID as a **One Shot** analysis on `target.bin`.
   Confirm `checksum` and `clamp` get renamed automatically via Single
   Match, each with a Function ID Analyzer bookmark and comment naming your
   `my-toy-lib` library — while `main`/`report` (unique to each binary) stay
   untouched.

**Check yourself:** `target.bin` was imported completely fresh, sharing no
symbols, project, or filename with `reference.bin` — so what exactly did
Function ID compare to produce a match?
