# Solution: Control-Flow & Reference Analysis

1. It should be a `COMPUTED_CALL` (or `CONDITIONAL_COMPUTED_CALL`/similar if
   your compiler folds in a branch — unlikely here), since the call target
   comes from a register loaded out of memory, not a literal encoded in the
   instruction.
2. Create Default Reference can only add a reference to something the
   disassembler can resolve statically at the operand it's pointed at —
   here that's the *load* from the `ops` array, so you get (or already have)
   a data reference to the array's address. It cannot follow the
   array-index-then-load-then-jump chain all the way to whichever function
   pointer happens to live there at runtime.
3. `op_add`/`op_sub` still get `FUN_<addr>` names (or after auto-analysis,
   possibly no reference-driven prefix at all if nothing in the binary
   references them via a resolvable operand) — because the only "call" to
   them is indirect, no static `CALL <op_add>`-style reference exists for
   Ghidra to hang a `SUB_` name on the way it would for a direct call.
4. The data-flow graph should show a `LOAD` node reading from the `ops`
   array (fed by the array-index computation from `param_1`), with its
   output feeding directly into the `CALL` node's target operand — the
   graphical version of "the callee is a runtime value."
5. Flow override matters when the *disassembler's* categorization of an
   instruction is wrong — e.g. hand-obfuscated code that repurposes a
   `RETURN` opcode as an indirect `BRANCH`, or a `CALL` that's actually being
   used as a disguised jump. This binary's `CALL` really is a call, so
   nothing needs overriding.

**Check yourself — answer:** because the indirect call's actual target is a
*runtime value* — read from memory and only known once the program
executes — not a static operand the disassembler can decode ahead of time.
A direct call encodes its target address right in the instruction, so
static analysis can follow it immediately; an indirect call through a
function-pointer array can only be *approximated* statically (e.g. by
knowing all the possible values that could end up in the array), which is
exactly the kind of thing Ghidra's static analysis and reference model
can't guarantee.
