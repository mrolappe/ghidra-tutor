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
| 05 | [automation-scripting](05-automation-scripting/) | Java/Jython API, Ghidrathon, headless analyzer |
| 06 | [ai-assisted-ghidra](06-ai-assisted-ghidra/) | MCP server setup, AI-assisted RE workflows |

Each module has numbered guides plus `exercises/<slug>/{problem.md, sample/, solution.md}`.

Cross-cutting extras (flashcards, lab-notebook template, printable cheatsheets)
land in a later polish pass — see `BACKLOG-future-topics.md` for topics beyond
the current scope.

## Legal note on exercise binaries

No copyrighted ROMs or commercial games are used. Sample binaries are either
self-built with free cross-assemblers/compilers (vasm/vbcc for 68000, cc65 for
6502) or freely distributable PD/homebrew/demoscene material.

## Progress

See [PLAN.md](PLAN.md) for the full curriculum plan and [PROGRESS.md](PROGRESS.md)
for what's done and what's next — each work session picks up from there.
