# Solution: Basic Annotations

Matching the behavior descriptions back to `sample.c`:

- calls `printf` with `[LOG] %s\n`, called from 4 places → **`log_message`**
- adds two parameters, called from one place → **`add_values`**
- calls the logger, has a `1337` local added to `add_values`'s result →
  **`compute_score`** (the `1337` local is the flat bonus/base score baked
  into every call — name it something like `base_score` or `magic_bonus`)
- calls the logger, returns `param_1 - 10` → **`compute_penalty`**

1. After renaming, the Decompiler view for `main` should now read close to
   the original source (`log_message("starting up"); compute_score(42, 8);
   ...`) instead of `FUN_<addr>(...)`.
2. Retyping doesn't have to change the type to do something — the dialog
   opening at all from a Decompiler local confirms `Ctrl+L` reaches
   `RetypeLocalAction` regardless of whether you pick a different type.
3. No fixed wording — just confirm the Plate comment renders as a `*`-boxed
   banner directly above the function in both Decompiler and Listing.
4. The Repeatable comment should appear next to all 4 call sites of
   `log_message` in the Listing (as long as none of those call sites already
   has its own EOL/Repeatable comment set) — that's the "repeats at every
   reference" behavior, distinct from a plain EOL comment which only shows
   once, where you set it.

**Check yourself — answer:** the Listing. A Decompiler variable's name isn't
separate text — it's backed by the same symbol/variable-storage the Listing
reads, so renaming in one is renaming the actual symbol, visible in both.
