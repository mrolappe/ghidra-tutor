# Exercise: Decompiler Tuning

Covers [`02-decompiler-tuning.md`](../../02-decompiler-tuning.md). Reuses the
`sample.bin` project from [`01-data-types`](../01-data-types/) — same
program, no rebuild needed.

## Tasks

1. Open the function that computes a result by indexing into a small array
   of two entries and calling through it (this is `apply_op`) — e.g.
   `(**(code **)(&DAT_<addr> + (long)param_1 * 8))(param_2,param_3)`. This is
   a call through a function pointer selected at runtime — the Decompiler
   can't know at analysis time whether it's calling the add-function or the
   subtract-function, so it shows a generic prototype for the call.
2. Right-click that call in the Decompiler → **Override Signature** and set
   it explicitly to `int (int, int)`. Confirm the call site now renders with
   typed `int` arguments/return instead of an `undefined`-typed call. Note
   that this only affects *this call site* — the two functions actually
   being called through the pointer are untouched.
3. Find the two tiny functions the pointer array holds (`op_add`, `op_sub` —
   one returns `param_1 + param_2`, the other `param_1 - param_2`). Put the
   cursor on one and press **F** (Edit Function...) to open the Function
   Editor Dialog. Check the **Calling Convention** combobox (note what your
   platform's `.cspec` offers — it won't be the Windows names from the
   guide), rename both parameters to `a`/`b`, and make sure **Commit all
   return/parameter details** ends up checked before clicking OK.
4. Add the **Signature Source** field to the Function Listing (or just note
   it in the Function Editor) for the function you just edited — confirm it
   now reads `USER_DEFINED`.
5. On `total_quantity`, if the Decompiler already infers a clean `int`
   loop/parameter signature without you touching anything, promote it
   directly: right-click → **Commit Params/Return** (shortcut **P**) —
   confirm this also flips its Signature Source to `USER_DEFINED` without
   you having hand-retyped anything.

**Check yourself:** suppose you re-run Auto Analysis on this program after
finishing step 3. Per the Signature Source priority table, does your
`USER_DEFINED` edit on `op_add`/`op_sub` survive, or does Auto Analysis
overwrite it? Why?
