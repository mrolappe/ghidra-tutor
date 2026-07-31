# Control-Flow & Reference Analysis

00-quickstart/05 covered the basics of xrefs (Show References To, the
inline `XREF[n]:` display, bookmarks). This guide goes deeper: what a
reference actually *is* under the hood, how to read and override control
flow, and how to graph P-Code directly.

## Reference types

A reference is either a **flow** (control-flow) reference or a **data**
reference. Both are represented as a `RefType`; flow references specifically
use the `FlowType` subclass. The full set shipped in 12.1.2:

**Flow types** (control flow): `INVALID`, `FLOW` (generic/complex),
`FALL_THROUGH` (reserved, internal), `UNCONDITIONAL_JUMP`,
`CONDITIONAL_JUMP`, `UNCONDITIONAL_CALL`, `CONDITIONAL_CALL`, `TERMINATOR`,
`COMPUTED_JUMP`, `CONDITIONAL_TERMINATOR`, `COMPUTED_CALL`,
`CALL_TERMINATOR`, `COMPUTED_CALL_TERMINATOR`,
`CONDITIONAL_CALL_TERMINATOR`, `CONDITIONAL_COMPUTED_CALL`,
`CONDITIONAL_COMPUTED_JUMP`, `JUMP_TERMINATOR`, `INDIRECTION`, and four
override-marker types used internally by the flow-override feature below:
`CALL_OVERRIDE_UNCONDITIONAL`, `JUMP_OVERRIDE_UNCONDITIONAL`,
`CALLOTHER_OVERRIDE_CALL`, `CALLOTHER_OVERRIDE_JUMP`.

**Data types** (non-flow): `THUNK`, `DATA`, `PARAM`, `DATA_IND`, `READ`,
`WRITE`, `READ_WRITE`, `READ_IND`, `WRITE_IND`, `READ_WRITE_IND`,
`EXTERNAL_REF`.

Source:
`Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/symbol/RefType.java`.

### Default symbol naming from reference type

When a reference is created and there's no symbol yet at the destination,
Ghidra auto-generates one, and the prefix tells you what kind of reference
produced it:

| Prefix | Meaning |
|---|---|
| `LAB_<addr>` | branch-flow destination |
| `SUB_<addr>` | call-flow destination |
| `DAT_<addr>` (or a type-named prefix like `DWORD_<addr>` if the address holds defined data) | data reference destination |
| `OFF_<addr>` | offcut reference destination (points into the middle of a code unit) |

So `SUB_0040abcd` vs `LAB_0040abcd` at the same address is itself a signal —
it tells you whether something reaches that address via a call or a plain
jump.

Source:
`Ghidra/Features/Base/src/main/help/help/topics/ReferencesPlugin/References_from.htm`
("Reference Destination Symbols").

## Creating and deleting references manually

With the cursor on a mnemonic or operand in the Listing, the ReferencesPlugin
offers three actions:

- **References → Add Reference from...** — opens the Add Reference dialog,
  letting you set any permitted reference type (Memory, External, Stack,
  Register) explicitly.
- **References → Create Default Reference** — default shortcut **Alt+R**.
  Creates the default primary reference for the current operand; the exact
  menu wording changes based on what it would create ("Create Memory
  Reference", "Create Stack Reference", "Create Register Reference"). For a
  scalar operand in a program with multiple memory spaces, invoking it
  repeatedly cycles through the candidate spaces.
- **References → Delete References** — removes the reference(s) on the
  current mnemonic/operand.

Ghidra doesn't allow mixing reference *types* on one mnemonic/operand
(except that Memory References can coexist as multiple memory refs); adding
a different-typed reference replaces what was there.

Source:
`Ghidra/Features/Base/src/main/help/help/topics/ReferencesPlugin/References_from.htm`
("Actions for Creating and Deleting References From a Code Unit" — `{Alt-R}`
key-binding notation from the doc itself).

## Overriding control flow

Sometimes the disassembler's guess about how an instruction actually
transfers control is wrong (common with hand-obfuscated jump tables, or
processor-specific quirks the SLEIGH spec doesn't fully model). Two
independent override mechanisms:

### Flow override (branch ↔ call ↔ return)

Right-click an instruction → **Modify Instruction Flow...** (no default
keybinding) opens the Set Flow Override dialog. It reassigns the
*semantic category* of a call/branch/return using one of:

| `FlowOverride` value | Effect |
|---|---|
| `NONE` | no override (default) |
| `BRANCH` | treat a CALL or RETURN as a JUMP |
| `CALL` | treat a BRANCH or RETURN as a CALL |
| `CALL_RETURN` | treat a BRANCH, CALL, or RETURN as a CALL immediately followed by a RETURN |
| `RETURN` | treat a BRANCH or CALL as a RETURN |

This changes the P-Code Ghidra generates for the instruction (e.g. `BRANCH`
value maps `CALL → BRANCH`, `CALLIND → BRANCHIND`), which is why it also
changes what the Decompiler renders and how the Function Graph draws edges
out of that instruction.

Source:
`Ghidra/Framework/SoftwareModeling/src/main/java/ghidra/program/model/listing/FlowOverride.java`
(enum values + P-Code mapping in Javadoc);
`Ghidra/Features/Base/src/main/java/ghidra/app/plugin/core/disassembler/SetFlowOverrideAction.java`
(popup menu text "Modify Instruction Flow...", no `KeyBindingData` call —
no default shortcut).

### Fallthrough override

Independent of flow override: right-click an instruction → **Fallthrough →
Set...** opens the Set Fallthrough Address dialog to force a specific
fallthrough address (or clear it to None). Useful when data was
misidentified as skippable and the "next" instruction the disassembler
picked isn't actually the real continuation. **Fallthrough → Auto
override** skips over interleaved data to find the real next instruction
automatically (single instruction or over a selection); **Fallthrough →
Clear Overrides** removes it. An overridden fallthrough shows a "Fallthrough
Override" comment at the address.

Source:
`Ghidra/Features/Base/src/main/help/help/topics/FallThroughPlugin/Override_Fallthrough.htm`.

## Graphing P-Code directly

Beyond the Function Graph (00-quickstart/03 — basic-block view of a
function), the Decompiler can graph the underlying P-Code itself, which is
the more precise view when you're debugging *why* the Decompiler produced
what it did:

- **Graph → Graph Control Flow** — the P-Code control-flow graph
  (`PCodeCfgAction`, menu bar group "graph").
- **Graph → Graph Data Flow** — the P-Code data-flow graph
  (`PCodeDfgAction`, menu bar group "graph").

Both require a Graph Display Broker service configured in the tool (Ghidra
ships one by default); neither has a default keyboard shortcut.

Source:
`Ghidra/Features/Decompiler/src/main/java/ghidra/app/plugin/core/decompile/actions/PCodeCfgAction.java`
and `PCodeDfgAction.java`.

## Location References, revisited

00-quickstart/05 covered **Show References To** (Ctrl+Shift+F). The same
Location References Dialog also works on **data types**: right-click a type
in the Data Type Manager (or in the Decompiler/Listing where it's applied)
→ Find References To/Find Uses Of shows every location that type is used —
in function signatures as well as applied to memory — and highlights the
type in the Data Type Manager tree. Rows backed by an actual database
reference are deletable; rows that are dynamic (inferred, e.g. by the
Decompiler) or general "uses" are not.

Source:
`Ghidra/Features/Base/src/main/help/help/topics/LocationReferencesPlugin/Location_References.html`.

---

**Self-check:** you see `SUB_00401020` in the Listing but you know that
address is only ever reached via an indirect jump table, never called —
what does the `SUB_` prefix tell you happened, and which action fixes it? →
`SUB_` means a *call*-type reference created that symbol; if the real
transfer is a jump, use **Modify Instruction Flow...** (or fix the
underlying reference type) rather than just renaming the label.
