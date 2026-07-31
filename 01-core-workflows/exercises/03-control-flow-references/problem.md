# Exercise: Control-Flow & Reference Analysis

Covers
[`03-control-flow-reference-analysis.md`](../../03-control-flow-reference-analysis.md).
Reuses the `sample.bin` project from [`01-data-types`](../01-data-types/).

## Tasks

1. Navigate to the CALL instruction inside `apply_op` that goes through the
   two-entry function-pointer array. Right-click it → **References → Show
   References From...** (or just inspect the instruction) and confirm its
   `RefType`/`FlowType` is a **computed** call variant, not a plain
   unconditional call — this is the disassembler telling you the target
   isn't a fixed address.
2. Try **References → Create Default Reference** (**Alt+R**) on the call's
   operand. Observe what it actually resolves to: a reference to the `ops`
   array's memory location (where the pointer is read *from*), not to
   `op_add`/`op_sub` directly.
3. Compare naming prefixes: check what `op_add` and `op_sub` are named before
   you rename them. Since the only thing reaching them is entries in a data
   array read at runtime — not a direct call instruction Ghidra's static
   analysis resolved — confirm whether they show up with `SUB_`/`FUN_`
   naming or something else, and think about why.
4. Open **Graph → Graph Data Flow** for `apply_op`. Find the load that reads
   an entry from the `ops` array and trace the edge from that load into the
   CALL node — this is the P-Code-level view of exactly the ambiguity from
   steps 1–2.
5. This binary's compiler emitted a normal, correctly-detected `CALL`
   instruction, so there's nothing to fix with **Modify Instruction
   Flow...** here — but explain in one sentence what situation *would* call
   for it (see the guide's `FlowOverride` table).

**Check yourself:** why can't **Create Default Reference** resolve the
indirect call's operand all the way to `op_add` or `op_sub`, when it can
clearly resolve a direct call's operand to the called function?
