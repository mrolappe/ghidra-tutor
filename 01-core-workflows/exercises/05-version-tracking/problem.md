# Exercise: Version Tracking Basics

Covers [`05-version-tracking.md`](../../05-version-tracking.md). Own sample
pair — see [`sample/`](sample/): `v1.bin` and `v2.bin`, two "versions" of the
same small program, deliberately evolved so each function needs a different
matching strategy:

| Function | Change from v1 → v2 |
|---|---|
| `validate` | unchanged, same position |
| `format_result` | unchanged body, but moved earlier in the file (different address) |
| `compute` | same structure, one constant changed |
| `bonus` | new in v2, doesn't exist in v1 |

## Build

```sh
cd sample
./build.sh
```

Import both `v1.bin` and `v2.bin` into one project and auto-analyze both.

## Tasks

1. Open the Version Tracking Tool (blue-footprints icon in the Project
   Window/Tool Chest). Drag `v1.bin` and `v2.bin` onto it as source and
   destination respectively (swap if Ghidra guessed backwards), and create a
   new session.
2. Run only the **exact** correlators (Exact Function Bytes Match, Exact
   Function Instructions Match) via the green-plus wizard. Select all rows
   in the Matches table (**Ctrl+A**) and **Apply Markup**.
3. Confirm the results: `validate` matches (unchanged). Confirm
   `format_result` **also** matches even though it moved to a different
   address in the file — exact correlators match on content, not position.
   Confirm `compute` does **not** appear matched yet (its bytes/instructions
   differ because of the changed constant), and `bonus` naturally has no
   source-side counterpart at all.
4. Run one more correlator: **Exact Function Mnemonics Match**. Confirm
   `compute` now shows up as a match — this correlator ignores the actual
   values of immediate operands, so "same instructions, different constant"
   still counts as a match. Review and accept it (it isn't auto-applied the
   way exact-bytes matches effectively are).
5. Confirm `bonus` never gets a match candidate from any correlator you ran
   — it's genuinely new code with nothing on the source side to match
   against.
6. Optional: start a fresh session and run **Automatic Version Tracking**
   instead of doing steps 2–4 by hand. Compare which of the four functions
   it resolves automatically versus what you had to review yourself.

**Check yourself:** which of the four functions would the *exact*
correlators alone (bytes/instructions) completely miss, and which
correlator from the guide's list is purpose-built for exactly that
"same logic, different constant" case?
