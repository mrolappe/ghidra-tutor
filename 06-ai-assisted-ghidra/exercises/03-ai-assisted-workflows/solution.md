# Solution: Running the triage workflow, by hand first

## Part A

1. **Memory layout.** The one fact that matters most: **the load address**.
   A PRG has no section headers, no ELF/Hunk-style block list — just a
   2-byte little-endian load address followed by raw bytes
   (`04-retro-c64/04-prg-cartridge-formats.md`). `get-memory-blocks` on a
   correctly-imported PRG should show one block starting at that address (in
   `sample.prg`'s case, wherever `ca65`'s `c64-asm.cfg` places `CODE` — see
   that guide's caveat about not asserting cc65's exact output without
   inspecting your own build). If the agent reports a *different* load
   address than what the file's own first two bytes say, that's an import
   mistake to catch immediately, before anything else.
2. **Strings.** Essentially nothing useful here — `sample.s` contains no
   string literals at all, just instructions and immediate byte values.
   This matches guide 3 directly: retro binaries, and *this* one especially
   (it's a recognition-pattern demo, not a real program), are string-poor
   compared to a modern CTF/malware binary. Don't expect a strings survey to
   carry the triage the way it would for a Windows PE.
3. **Symbols — every address that's unnamed after import**:
   - `$ffd2` (the `jsr` target) — KERNAL CHROUT
   - `$01` (the `sta $01` target) — the 6510 processor port, not a
     KERNAL/BASIC symbol but still unnamed zero-page RAM to Ghidra, per
     `04-retro-c64/01-6502-6510-recap.md`'s point that Ghidra has no
     separate 6510 language and can't see this port as special
   - `$d020`, `$d400`, `$d401`, `$d404` — VIC-II border-color register and
     SID voice-1 registers

   Every one of these needs a human- or table-sourced name; nothing about
   plain 6502 disassembly names them automatically.

## Part B

4. **`jsr $ffd2` → `CHROUT`**: the table is
   `04-retro-c64/03-kernal-basic-rom-references.md`'s 40-entry
   `$FF81`-`$FFF3` KERNAL jump table. Without it, an agent has nothing to
   go on but the bare address — there's no structural signal (unlike, say,
   a Windows import table) that `$ffd2` means anything at all.
5. **VIC-II/SID registers**: `04-retro-c64/05-vic-sid-registers.md`'s
   `$D000`-`$D02E` / `$D400`-`$D418` register tables. Same shape as #4 —
   these addresses are only meaningful against the fixed table, not
   derivable from the instruction stream itself.
6. **The bank-switch write**: you want the agent to show the actual bit
   decomposition, not just assert a conclusion — `$36` = `%00110110`:
   `LORAM=0` (BASIC ROM banked out), `HIRAM=1` (KERNAL stays banked in),
   `CHAREN=1` (I/O visible at `$D000`-`$DFFF`), against
   `04-retro-c64/02-memory-map-bank-switching.md`'s bit-weight table. "This
   disables BASIC ROM" is *correct but incomplete* — it says nothing about
   why the very next instruction (`jsr $ffd2`) still works, which depends
   on `HIRAM` specifically staying set so KERNAL remains banked in. An
   agent that shows the bit table earns more trust than one that states a
   plausible one-line conclusion.

## Check-yourself answer

The **bank-switch write** is the one most likely to produce a confidently
wrong answer from an ungrounded agent. CHROUT and the VIC-II/SID pokes are
each a single fixed lookup — either the agent has (or was given) the right
table and gets it right, or it doesn't and the guess is obviously
unsupported ("this looks like it prints something" is a hedge, not a
specific wrong claim). The bank-switch write is different: `$36` written to
`$01` is a **plausible-sounding target for a model trained on general
6502/C64 material to pattern-match against a half-remembered default value**
(the commonly-cited $37/$2F power-up values this course's own Phase 9
research flagged as unconfirmed — see `04-retro-c64/RESEARCH-NOTES.md`) and
assert a specific, wrong bit meaning with full confidence, because bit-level
reasoning about a control register is exactly the kind of "sounds like an
expert answer" territory an LLM is fluent in producing without necessarily
having done the arithmetic against the real bit-weight table. A single
lookup either has the fact or doesn't; a bit-decomposition claim can be
subtly wrong while still reading as authoritative — which is precisely why
step 6 asks you to demand the working, not just the conclusion.
