# Exercise: Basic Annotations

Covers [`04-basic-annotations.md`](../../04-basic-annotations.md). Reuses the
`sample.bin` project from
[`02-first-import-analysis`](../02-first-import-analysis/).

`sample.c`'s 4 stripped functions, by behavior (don't peek at the source
until you've matched them yourself from the decompiled output):

- one just calls `printf` with a `[LOG] %s\n` format and whatever string it's
  given — called from 4 different places.
- one adds its two parameters and returns the sum — called from exactly one
  place.
- one calls the logger, declares a local set to `1337`, then adds that local
  to the result of the two-argument adder.
- one calls the logger, then returns `param_1 - 10`.

## Tasks

1. In the Decompiler, identify all 4 by reading their bodies, then rename
   each (**L**) to something meaningful — e.g. `log_message`, `add_values`,
   `compute_score`, `compute_penalty`. Also rename their parameters (`L` on
   the parameter token) to something better than `param_1`.
2. On the function with the `1337` local: rename that local (**L**) to
   reflect what it represents, then retype it (**Ctrl+L**) — even if the
   type doesn't need to change, confirm the Retype Variable dialog opens
   from the Decompiler for a local.
3. Add a **Plate** comment (`;` on the function name / signature line) above
   your renamed "adder" function summarizing what it does.
4. Add a **Repeatable** comment (`;` on the call, choosing the Repeatable
   tab) on your renamed logging function's definition, explaining it's a
   shared logger. Then check two different call sites in the Listing —
   confirm the comment shows up at both without retyping it.

**Check yourself:** you renamed a variable in the Decompiler — what view
should also reflect the new name, and why?
