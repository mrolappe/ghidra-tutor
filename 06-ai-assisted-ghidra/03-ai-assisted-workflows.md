# AI-assisted RE workflows

ReVa's own repository ships **Claude Code skills** — `ReVa/skills/binary-triage/`,
`ReVa/skills/deep-analysis/`, plus three CTF-specific ones — installable via:

```sh
claude plugin marketplace add cyberkaida/reverse-engineering-assistant
```

These are written for modern binaries (Windows/Linux malware and CTF
targets: imports, `.rodata`, `IsDebuggerPresent`-style anti-analysis checks).
This guide doesn't repeat them; it adapts the same *shape* — survey before
you dive, work outward from what's already named — to the retro platforms
this course actually covers, and names the concrete ReVa MCP tools involved
so you know what you're approving at each permission prompt.

## The workflow that transfers: triage, then targeted analysis

Binary-triage's structure — identify the program, survey memory layout,
survey strings, survey symbols, *then* look at functions — works
unchanged for a Hunk/PRG/CRT binary, with retro-specific substitutions:

1. **Identify the program.** `get-current-program` / `list-project-files`.
   No different from a modern binary.
2. **Survey memory layout.** `get-memory-blocks`. On a retro target this is
   where you'll actually see the platform: a flat `$0000`-`$FFFF` C64 map
   with I/O-space overlaps (`04-retro-c64/02-memory-map-bank-switching.md`),
   or Hunk's CODE/DATA/BSS block sequence
   (`02-retro-amiga/02-hunk-executable-format.md`), rather than ELF/PE
   sections.
3. **Survey strings.** `get-strings-count` / `get-strings`. Still useful,
   but retro binaries are string-poor compared to modern ones — don't expect
   this step to carry as much signal as it would on a CTF binary.
4. **Survey symbols.** `get-symbols-count` / `get-symbols`. This is where
   retro RE diverges most: there *is* no import table. What you have instead
   is the **unnamed-call problem** every platform module in this course
   already taught — `jsr -552(a6)` (Amiga LVO), `trap #1` with a function
   number in `d0` (Atari GEMDOS), `jsr $ffd2` (C64 KERNAL). None of these
   show up as a named symbol until *something* — you, or the AI, consulting
   the LVO/TRAP/KERNAL tables from modules 02-04 — annotates them.
5. **Functions**, last, once the above has given you a map.

## Where an AI agent actually helps on this course's material

The unnamed-call problem is exactly the kind of task an LLM is well-suited
to *propose* an answer for and poorly suited to be *trusted* on unreviewed:

- Given a disassembly snippet containing `jsr -552(a6)`, an agent that's
  been pointed at (or has memorized) the LVO table can suggest
  `_LVOOpenLibrary` and even auto-apply the rename via ReVa's
  `rename-function`/`rename-variable` tools.
- Same shape for `trap #1` + `move.w #$4a,-(sp)` → `Mshrink`, or
  `jsr $ffd2` → `CHROUT`.
- Once names land, ask the agent to propagate: "this function calls
  `_LVOOpenLibrary` then checks the result for null before storing it — is
  this an init routine? Give it a name and a one-line comment." This is a
  legitimate multiplier — it's the same annotation work
  `01-core-workflows/02-basic-annotations.md` (00-quickstart) already has
  you doing by hand, just faster.

What the agent is *not* well-suited for, and shouldn't be trusted on
unreviewed: platform-specific facts it wasn't given source for. An LLM
asked "what does LVO offset -1274 do" without being pointed at the actual
NDK `.fd` file (guide 1's field-wide gap: nobody sanitizes tool-result text,
and nothing stops a model from confidently inventing a plausible-sounding
LVO name) is guessing from training data, not reading your binary. Guide 4
covers the review discipline this implies in more depth.

## A concrete session shape

For a retro sample (say, one of this course's own `sample.bin`/`sample.hunk`
exercises):

1. Import and run auto-analysis yourself first, or let the agent drive
   `get-current-program` against an already-open project — either way,
   confirm what's actually loaded before asking questions about it.
2. Ask for a memory-layout survey and a plain-language summary of what
   sections/blocks exist.
3. Ask the agent to list functions with default (`FUN_`/`LAB_`-style) names
   and cross-reference against the platform's call table for this module —
   e.g. "which of these functions call something in the `$FFD2`-`$FFF3`
   KERNAL range, and what's the call?"
4. Review each proposed rename against the actual decompiled code before
   accepting it (guide 4's exercise walks this step by step) — don't batch-
   accept a list of renames without opening at least the ones you didn't
   already recognize yourself.
5. Once the call sites are named, ask for a summary of program behavior —
   this is where the agent's speed advantage over manual annotation
   actually shows up, because steps 1-4 already grounded it in your binary
   instead of a guess.

---

**Self-check:** why does the binary-triage skill's "survey symbols" step
carry *less* signal on a C64 `sample.prg` than on a Windows PE, and what do
you substitute for it? → A PE's import table names external library calls
directly (`CreateFileW`, `connect`, ...); a 6502 binary has no equivalent —
every KERNAL/BASIC-ROM call is a bare `jsr $ffd2`-style address with no
symbol at all until something (you or the agent, working from
`04-retro-c64/03-kernal-basic-rom-references.md`'s jump-table) names it. The
substitute is the platform's fixed call table, not the binary's own symbol
table — which is exactly the unnamed-call pattern this course has taught
since Amiga.
