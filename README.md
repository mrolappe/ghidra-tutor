# Ghidra Tutor

A staged, hands-on Ghidra reverse-engineering curriculum: quickstart basics, core
day-to-day workflows, a retro-computing specialization (Amiga → Atari ST → C64),
and automation/scripting including AI-assisted workflows via MCP.

Later modules build on earlier ones — work through them roughly in order.

## Modules

| # | Module | Focus |
|---|--------|-------|
| 00 | [quickstart](00-quickstart/) | Install, first project, UI tour, everyday basics |
| 01 | [core-workflows](01-core-workflows/) | Data types, decompiler tuning, FID, version tracking |
| 02 | [retro-amiga](02-retro-amiga/) | 68000, Hunk format, AmigaOS/Kickstart, custom chips |
| 03 | [retro-atari-st](03-retro-atari-st/) | 68000/TOS, GEMDOS/BIOS/XBIOS, PRG format |
| 04 | [retro-c64](04-retro-c64/) | 6502/6510, memory map, KERNAL ROM, VIC-II/SID |
| 05 | [automation-scripting](05-automation-scripting/) | Java API, Jython/PyGhidra scripting, headless analyzer |
| 06 | [ai-assisted-ghidra](06-ai-assisted-ghidra/) | MCP server setup, AI-assisted RE workflows |

Each module has numbered guides plus `exercises/<slug>/{problem.md, sample/, solution.md}`.

## Cross-cutting extras

- [`flashcards.csv`](flashcards.csv) — Anki-importable deck (shortcuts,
  register names, format field names) for the things you just have to
  memorize. Import via Anki's File → Import, comma-separated, 3 fields
  (Front, Back, Tags).
- Printable one-page cheatsheets per retro platform:
  [Amiga](02-retro-amiga/cheatsheet-print.md),
  [Atari ST](03-retro-atari-st/cheatsheet-print.md),
  [C64](04-retro-c64/cheatsheet-print.md).
- [`lab-notebook-template.md`](lab-notebook-template.md) — a copy-per-exercise
  template for structured RE notes.
- [`BACKLOG-future-topics.md`](BACKLOG-future-topics.md) — topics considered
  and deliberately left out of this course's scope.

## Legal note on exercise binaries

No copyrighted ROMs or commercial games are used. Sample binaries are either
self-built with free cross-assemblers/compilers (vasm/vbcc for 68000, cc65 for
6502) or freely distributable PD/homebrew/demoscene material.

## Progress

See [PLAN.md](PLAN.md) for the full curriculum plan and [PROGRESS.md](PROGRESS.md)
for what's done and what's next — each work session picks up from there.
