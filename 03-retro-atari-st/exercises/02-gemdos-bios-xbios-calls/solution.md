# Solution: GEMDOS/BIOS/XBIOS Call Recognition

1. Both are `TRAP #1`, so both are GEMDOS calls — no ambiguity, the TRAP
   number alone fully determines the API layer (GEMDOS/BIOS/XBIOS map 1:1
   to `TRAP #1`/`#13`/`#14`).
2. It doesn't contradict the guide — it's just the degenerate case of the
   same shape. `Mshrink()` and `Pexec()` normally do take arguments in real
   code, but `sample.s` is a non-functional recognition demo (like
   `02-retro-amiga`'s sample), and the guide's own illustrative snippets for
   both `Mshrink()` and `Super()` show exactly this bare
   opcode-then-`trap` shape with no arguments drawn in either. The general
   rule (args reverse-order, then opcode, then trap) still holds; this demo
   simply has zero arguments to push.
3. Something like `Mshrink() — GEMDOS $4A, TRAP #1` on the first `trap #1`,
   and `Super() — GEMDOS $20, TRAP #1` on the second.
4. `TRAP #14` is XBIOS. Look up opcode `0x3E` (62 decimal) in the Atari
   Compendium's Book 4 opcode index, or the equivalent function list on
   [FreeMiNT's `tos.hyp`](https://freemint.github.io/tos.hyp/) — Ghidra has
   no built-in table for this, so an external reference is the only way to
   get the function name.
5. `czietz/ghidraScripts_for_Atari` — per the guide, it lists "a script to
   annotate TRAPs (OS calls) according to function number" under its own
   "ideas for future development," meaning as of that project's current
   state this specific gap (auto-naming TRAP calls) is not yet closed by
   the community tooling either — manual lookup (or a future
   `05-automation-scripting` script of your own) is still the practical
   path.

**Check yourself — answer:** the TRAP number only selects which *table* of
functions applies (GEMDOS vs. BIOS vs. XBIOS) — it says nothing about which
row of that table is being called. That's what the 16-bit immediate pushed
right before the trap encodes, and Ghidra disassembles that immediate as a
plain number with no attached meaning, so resolving it to an actual function
name always requires the immediate value plus an external opcode-to-name
table (Compendium/`tos.hyp`/a script), never the TRAP number alone.
