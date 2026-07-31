# Solution: XRefs, Bookmarks, Search

1. 4 references: from `main` (2 calls — "starting up" and "done") and from
   `compute_score`/`compute_penalty` (1 call each — "computing score" and
   "computing penalty").
2. Same 4 in this binary, because every call here is a direct call — Ghidra
   records those as references automatically during Auto-Analysis, so the
   inline display already has everything "Show References To" finds.
3–4. No fixed output — just confirm the bookmark's address matches
   `compute_score`'s entry point, and that clicking the row in the Bookmarks
   window navigates the Listing there.
5. Matches inside `compute_score` (`"computing score"`) and
   `compute_penalty` (`"computing penalty"`) — both contain the substring
   `computing`.
6. `4C 4F 47` is `L`, `O`, `G` in ASCII — the search should land on the
   `"[LOG] %s\n"` string used by every `log_message` call.

**Check yourself — answer:** task 1 ("Show References To"). It actively
searches rather than just displaying what's already recorded, so it has a
chance at resolving references Auto-Analysis couldn't statically prove (e.g.
by looking at what values actually flow into a function pointer). The inline
`XREF[n]:` display only ever shows references Ghidra already committed to
the database — an indirect call it couldn't resolve simply won't appear
there at all.
