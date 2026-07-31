# Exercise: XRefs, Bookmarks, Search

Covers
[`05-xrefs-bookmarks-search.md`](../../05-xrefs-bookmarks-search.md). Reuses
the `sample.bin` project, ideally after finishing
[`04-basic-annotations`](../04-basic-annotations/) (renamed functions make
this easier to follow, but isn't required — `FUN_<address>` works too).

## Tasks

1. Put the cursor on your renamed logging function (`log_message`) and open
   **Show References To** (right-click → References → Show References
   to..., or `Ctrl+Shift+F`). Confirm it lists **4** call sites.
2. Compare that to the inline `XREF[n]:` text shown right at the function's
   definition in the Listing — same 4, since every reference here is a plain
   direct call already known to Ghidra. (The difference between the two only
   shows up on trickier binaries with indirect calls; note that for later.)
3. Right-click at the entry of your renamed `compute_score` function in the
   Listing → **Bookmark** → create a Note bookmark (description: anything,
   e.g. "score calc entry point").
4. Open the **Bookmarks window** (`Window → Bookmarks`, `Ctrl+B`). Confirm
   your bookmark is listed, then click it and confirm the Listing jumps
   there.
5. `Search → Program Text` (`Ctrl+Shift+E`) for the text `computing`. Confirm
   it finds matches inside **two** different functions (the two string
   literals that share that word).
6. `Search → Memory` (`S`) for the hex bytes `4C 4F 47` (ASCII "LOG") in Hex
   format. Confirm it finds a hit inside the `[LOG] %s\n` string.

**Check yourself:** if this binary had an indirect call to `log_message`
through a function pointer, would task 1 or task 2 be more likely to still
find it — and why?
