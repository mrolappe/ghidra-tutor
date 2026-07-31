# Solution: Review before you accept

## Part A

1. **No.** `int *` arithmetic advances 4 bytes per index step. The actual
   code advances `local_14 * 0x18` — **24 bytes** per step. Whatever
   `param_1` points at, it isn't a flat array of `int`; each element is
   (at least) 24 bytes wide. Accepting the `int *` retype as proposed would
   make every future decompile of this function show `param_1[local_14]`-
   style indexing that's simply wrong — off by a factor of 6.
2. The `+ 4` inside `*(int *)(param_1 + local_14 * 0x18 + 4)` says the
   summed value isn't the whole 24-byte element — it's a 4-byte **field**
   sitting 4 bytes into each element. That's exactly the struct-recovery
   signal `01-core-workflows/01-data-types-structures.md` teaches you to
   read: stride = struct size, offset = field position. (For what it's
   worth, this is ground truth, not a guess: the real source this binary
   was built from — `01-core-workflows/exercises/sample/sample.c` — defines
   `typedef struct { int id; int quantity; char name[16]; } Item;`, which
   is exactly 4 + 4 + 16 = 24 = `0x18` bytes, with `quantity` at offset 4.
   The decompiler output above was captured from the real stripped binary;
   this function is `total_quantity()`.)
3. The retype to actually apply: define a 24-byte (`0x18`) structure in the
   Data Type Manager with a 4-byte field at offset 0, a 4-byte field at
   offset 4 (the one this function reads), and a 16-byte char array at
   offset 8 — then retype `param_1` as a pointer to that structure (not
   `int *`). Once applied, the decompiler stops showing raw pointer
   arithmetic and starts showing `param_1[local_14].field_0x4`-style access
   for every future decompile of any function touching this same struct —
   the concrete payoff `01-data-types-structures.md` already demonstrated
   for exactly this reason.

## Part B

4. **No bounds check exists anywhere in the function.** The entire body is
   one statement: index `PTR_FUN_100008000` by `param_1` and call whatever's
   there. No comparison, no clamp, no conditional branch — nothing that
   could reject an out-of-range `param_1` before the call.
5. Part A's error is **mechanically checkable in seconds** — compare the
   stride constant (`0x18`) against `sizeof(int)` and the mismatch is
   obvious. Part B's error requires you to **read the entire function body
   and confirm the absence of something** — there's no single fact to spot-
   check against, you have to trace the whole (admittedly short, here) code
   path and notice nothing is there. That asymmetry is the real danger:
   a false "this validates X" claim is exactly the kind of thing that
   survives a quick skim, because skimming looks for what's *there*, not
   for what's *missing*. If you accepted this comment unreviewed and later
   relied on it (e.g., ruling out an out-of-bounds function-pointer call as
   an attack surface because "the comment says it's validated"), you'd
   carry a false sense of safety into further analysis — worse than a
   mislabeled variable type, which just looks wrong the next time you read
   it.

## Part C

6. **Edit → Tool Options → "ReVa Tool Groups" → uncheck "Scripting"**, in a
   running Ghidra CodeBrowser session with ReVa's plugins enabled.
7. `reva.tool.groups.scripting=false` in the headless `.properties`
   config file.
8. **Yes, still executable.** Per `04-verification-and-limits.md`'s
   tool-to-group table (read directly from `McpServerManager.createProvidersForGroup()`
   in ReVa's source), function/symbol renames live in the `Core Analysis`
   group (`FunctionToolProvider`, `SymbolToolProvider`), not `Scripting`.
   `Scripting` is exactly one tool provider — arbitrary Python execution —
   and disabling it has **zero effect** on rename/retype/comment tools.
   Part A's bad retype could still land through ReVa with `Scripting`
   turned off; the toggle only removes the code-execution consequence, not
   the need to review renames and retypes by hand.

## Check-yourself answer

The plausible-sounding **behavioral** claim (Part B's shape) is both harder
to catch and, in this course's judgment, more common in practice — an LLM
is fluent at producing confident-sounding descriptions of what code "does"
or "prevents," because that's the shape of text it was trained on far more
than it was trained on doing careful stride arithmetic. A wrong type is a
single falsifiable fact sitting right next to the code that disproves it; a
wrong behavioral claim requires you to hold the entire function (or more)
in your head and actively check for an absence. That asymmetry is exactly
why `04-verification-and-limits.md` frames "read the actual code the
proposal is based on" as the non-negotiable step — mechanical claims
(types, offsets, calling conventions) are cheap to verify and easy to
prioritize; behavioral claims ("this validates," "this is called only
when," "this can't happen because") are the ones that deserve the most
deliberate scrutiny, precisely because they're the easiest to accept on
faith.
