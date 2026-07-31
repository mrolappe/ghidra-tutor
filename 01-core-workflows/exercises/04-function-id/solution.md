# Solution: Function ID

1. `checksum` loops over a byte buffer summing into an accumulator; `clamp`
   is two early-return bounds checks followed by a plain return — rename
   accordingly.
2–3. No fixed output — confirm the ingest summary reports processing your 2
   renamed functions from `reference.bin` (plus `main`, which FID also
   hashes but which won't usefully match anything since every binary's
   `main` differs).
4. `target.bin`'s three functions (`checksum`, `clamp`, `report`, plus
   `main`) all start as `FUN_<addr>` — it's a separately compiled, separately
   stripped binary with no relationship to `reference.bin` at the symbol
   level.
5. `checksum` and `clamp` should be renamed automatically, each getting a
   "Function ID Analyzer" bookmark and a comment naming `my-toy-lib`
   version `1.0` as the source. `main` and `report` are untouched — they're
   genuinely different code (different buffer sizes/values, an extra
   `printf` call, an extra wrapper function), so their hashes don't match
   anything in your database.

**Check yourself — answer:** the **instruction-hash of each function's
body** — full/specific hash over mnemonics, addressing modes, and (for the
specific hash) constant operand values, computed purely from the compiled
bytes of `checksum` and `clamp`. Nothing about names, project structure, or
filenames enters into it; the match succeeds only because those two
functions happen to compile to byte-identical instruction sequences in both
programs, which is exactly how FID recognizes statically-linked library
code with no accompanying symbols in the wild.
