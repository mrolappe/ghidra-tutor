# Exercise: Running the triage workflow, by hand first

Covers [`03-ai-assisted-workflows.md`](../../03-ai-assisted-workflows.md).
No live ReVa/AI-client session needed for this one — the point is to walk
guide 3's triage-then-targeted-analysis workflow yourself against a binary
you already know, so you can recognize what a correct AI-assisted run
should look like (and, in a later real session, whether an agent's answers
are actually grounded in the binary or just plausible-sounding).

Reuses `04-retro-c64/exercises/sample/sample.s` — the same shared program
04-retro-c64's exercises 01/02/03/05 already used you're already familiar
with, built via its `build.sh` into `sample.prg`.

## Part A — what would step-by-step triage surface?

Walk guide 3's five-step triage shape (identify → memory layout → strings →
symbols → functions) against `sample.prg`, using what you already know about
this program from the earlier C64 module (no need to re-derive addresses,
you have them from `sample.s` directly):

1. **Memory layout**: what would `get-memory-blocks` need to report for this
   program to be useful — i.e., what's the one fact about where this
   program's code lives that matters most for a C64 PRG specifically
   (hint: it's not a section name)?
2. **Strings**: would a strings survey find anything useful in this
   particular program? Why or why not — what does that tell you about how
   much you should weight this step for retro binaries generally, per guide
   3?
3. **Symbols**: list every address in `sample.s` that would show up as an
   *unnamed* call or reference after a plain import — no loader exists for
   PRG, per `04-retro-c64/04-prg-cartridge-formats.md`, so this is a raw
   binary import at the header's load address.

## Part B — targeted analysis: what does the agent need to be told?

4. For the `jsr $ffd2` call: what table, from which guide, would an agent
   need to have been pointed at (or already "know") to correctly propose
   the name `CHROUT` instead of leaving it as a bare address or guessing
   something plausible-but-wrong?
5. Same question for `sta $d020` and `sta $d400`/`$d401`/`$d404` — name the
   guide and table.
6. The `sta $01` bank-switch write (`lda #$36 / sta $01`) is a case where
   an agent *cannot* correctly explain the write's effect from the
   instruction alone — it needs to interpret `$36` as bits. What would you
   want the agent to actually show its work with, rather than just asserting
   "this disables BASIC ROM"?

**Check yourself:** of the three targeted-analysis items above (CHROUT,
VIC-II/SID registers, the bank-switch write), which one is most likely to
produce a *confidently wrong* answer from an AI agent that wasn't
specifically grounded in this course's reference tables, and why — what
about that one specific case invites plausible-sounding guessing more than
the other two?
