# Solution: UI Tour

2. The Decompiler's rendering of `main` is a synthesized view *of the same
   underlying program database* the Listing shows — clicking a call
   expression selects the corresponding address, and both views move their
   cursor there together.
3. You should see 5 entries: `main` plus 4 `FUN_<address>` entries (for
   `log_message`, `add_values`, `compute_score`, `compute_penalty` — not
   necessarily in that order; the Symbol Tree doesn't know the original
   names any more than the Listing does at this point).
4. Built-in types (`int`, `byte`, `word`, ...) are shown but not editable —
   only user-defined types (Structures/Unions/Enums/Typedefs) and derived
   types (Pointers/Arrays) can be created/changed.
5. No specific output — just confirm Ctrl+Space actually toggles the center
   view for whichever function has focus, without needing the toolbar/menu.

**Check yourself — answer:** they share the underlying program database. A
Decompiler expression isn't independent text — it's derived from (and
addressed against) the same disassembly the Listing shows, so navigating one
navigates the other.
