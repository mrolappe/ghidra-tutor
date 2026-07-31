# Exercise: UI Tour

Covers [`03-ui-tour.md`](../../03-ui-tour.md). Reuses the `sample.bin` project
from [`02-first-import-analysis`](../02-first-import-analysis/) — open that
project rather than rebuilding/reimporting.

## Tasks

1. **Listing**: navigate to `main` (double-click it in the Symbol Tree, or
   `G` → type `main`). Confirm it's already visible — no "open" step needed.
2. **Decompiler**: open it (`Ctrl+E`) for `main`. Click on the call to what
   Ghidra currently calls the first `FUN_<address>` inside `main` (this is
   `log_message`, but Ghidra doesn't know that yet). Confirm the
   corresponding line highlights in the Listing.
3. **Symbol Tree**: expand **Functions** and confirm you can see all 5
   functions from exercise 02.
4. **Data Type Manager**: open it (`Window → Data Type Manager`) and find the
   built-in `int` type under the Built-in category — confirm it's greyed out
   / not editable (built-ins can't be redefined).
5. **Function Graph**: with the cursor inside the function that calls
   `add_values` and reads `magic = 1337` (this is `compute_score`), open
   `Window → Function Graph`, then press **Ctrl+Space** to toggle back to
   Listing and again to return to the graph.

**Check yourself:** in task 2, why does clicking a line in the Decompiler
highlight something in the Listing at all — what do the two views actually
share?
