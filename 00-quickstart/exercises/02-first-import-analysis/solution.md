# Solution: First Import & Analysis

Exact function count and addresses depend on your OS/compiler/libc (this is a
natively-compiled binary, not a fixed cross-assembled one) — don't worry if
your numbers don't match another platform. What should hold everywhere:

4. **Functions list**: `sample.c` defines 5 functions (`main`,
   `log_message`, `add_values`, `compute_score`, `compute_penalty`). Auto-
   Analysis should find all 5, plus Ghidra may list imported/thunk entries
   for `printf` (and on some platforms, `libc` startup helpers like
   `frame_dummy` or `_init`/`_fini` — these come from the toolchain, not from
   `sample.c`, and are normal to see).
5. `main` keeps its name because it has external linkage — the compiler
   emits it as a global (dynamic) symbol so the OS loader can find your
   program's entry point. `strip`'s default behavior removes local/debug
   symbols but leaves global ones, and `log_message`, `add_values`,
   `compute_score`, `compute_penalty` are all declared `static` — local
   linkage only, so they lose their names and show up as `FUN_<address>` (or
   similarly for their parameters: `param_1`, `param_2`, ...).

**Check yourself — answer:** linkage. `main` is a global symbol (external
linkage, needed by the OS loader); the rest are `static` (internal linkage),
which is exactly what `strip` removes by default. This is also why real-world
stripped binaries almost always still have a recognizable `main`/`_start`
even when everything else is anonymous.
