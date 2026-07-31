# Solution: Version Tracking Basics

3. `validate` and `format_result` both match under the exact correlators —
   `format_result`'s address changed (it moved earlier in `v2.c`, ahead of
   `compute`), but Exact Function Bytes/Instructions Match compares the
   function's own content, not where it lives in memory, so the move
   doesn't affect the match. `compute` doesn't match yet: `x * 2 + 1` vs.
   `x * 2 + 3` differ at the immediate-operand level, which is precisely
   what Exact Bytes/Instructions Match is strict about. `bonus` has no
   source-side function to match at all — it's new in v2.
4. Exact Function Mnemonics Match matches on the *sequence of mnemonics and
   operand types*, deliberately ignoring literal operand values — so
   `compute`'s "add a constant" shape matches across v1/v2 even though the
   constant itself changed. This is not an exact-bytes match, so it needs
   your review/accept, unlike step 2's matches which you could blanket-apply.
5. Correct — no correlator run here has anything on the v1 side that could
   plausibly match `bonus`, since the function is genuinely absent from v1.
6. Automatic Version Tracking's fixed correlator sequence should resolve
   `validate`, `format_result`, and (once it reaches Exact Function
   Mnemonics Match in its sequence) `compute` largely on its own; `bonus`
   still won't get a match either way — Automatic VT trades completeness for
   a low false-positive rate, and "no source counterpart exists" isn't
   something any correlator can paper over.

**Check yourself — answer:** `compute` — its constant change means the exact
bytes/instructions correlators reject it, but **Exact Function Mnemonics
Match** is exactly the correlator described as matching on mnemonics while
ignoring operand values, which is why it's the one that recovers this case
without needing a fuzzier similarity correlator or manual review from
scratch.
