# Exercise: First Import & Analysis

Covers
[`02-first-project-import-analysis.md`](../../02-first-project-import-analysis.md).

## Build the sample

```sh
cd sample
./build.sh
```

This compiles `sample.c` with your platform's C compiler and strips it — the
resulting `sample.bin` carries no function/variable names, same as any
unfamiliar binary you'd throw at Ghidra for real. (Needs `cc`/`gcc`/`clang` +
`strip`; see comments in `build.sh` if you're on Windows.)

This same `sample.bin` is reused by exercises 03–05 — keep the Ghidra project
you create here around instead of re-importing each time.

## Tasks

1. Create a new **Non-Shared** project (any name/location).
2. `File → Import File...` and pick `sample/sample.bin`. Check the Importer
   Dialog's guessed format/language look sane, then OK.
3. Open it in CodeBrowser (double-click in the project tree if it didn't open
   automatically) and accept the Auto-Analysis prompt with default options.
4. Once analysis finishes, open the **Symbol Tree** (`Window → Symbol Tree`)
   and expand **Functions**. Write down how many functions you see.
5. Find the function Ghidra named `main` (its symbol survives — everything
   else in `sample.c` is `static` and got stripped). Note what the *other*
   function names look like by comparison.

**Check yourself:** why does `main` show up with its real name while every
other function in this binary shows up as `FUN_<address>`?
