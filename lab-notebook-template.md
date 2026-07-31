# RE Lab Notebook Template

Copy this into a new file per exercise/binary you analyze. The point is
building the habit of writing down *why* you believe something, not just the
conclusion — useful the next time you (or someone else) reopen the project
months later.

```markdown
# <binary name / exercise slug>

- Date:
- Platform / Ghidra language ID:
- Import method (Raw Binary base addr, or loader used):

## Goal
What am I trying to figure out in this session?

## Observations
Address / range — what I see — why it's notable
(e.g. `$DFF096` write right after a `move.w #$8210,...` — DMACON, enabling
bitplane + Copper DMA)

## Hypotheses
What I think is going on, and what would prove/disprove it.

## Confirmed facts
What I've actually verified (cross-ref, xref, cited guide/spec section) —
distinct from "Hypotheses" above; don't let a guess quietly become a fact.

## Open questions
What's still unclear, and where I'd look next.

## Annotations applied
Renames/retypes/comments made in this session, so a diff against the
project is explainable later.
```
