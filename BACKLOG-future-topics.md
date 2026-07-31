# Backlog: Future Topics

Ideas identified while scoping this curriculum that are out of scope for the
current 7 modules — not because they're less valuable, but because each is
either a large course on its own or only relevant if your interests extend
past retro-platform reverse engineering. Kept here as pointers, not
elaborated.

- **Dynamic analysis alongside emulators** (WinUAE, Hatari, VICE) — pairing
  Ghidra's static view with a debugger-capable emulator (breakpoints, memory
  watch, live register state) would resolve several "can't tell without
  running it" cases this course flags statically (bank-switch state on C64,
  Copper-list timing on Amiga, `Super()` mode-switch effects on Atari ST).
- **BSim / Version Tracking in depth** — `01-core-workflows/05` covers VT
  basics for a single pair of binaries; a deeper module could cover BSim
  similarity search and patch-diffing across many versions of one program
  (e.g. tracking a KERNAL ROM revision-to-revision, or a game's release
  history).
- **Writing custom SLEIGH processor modules** — relevant for exotic/custom
  silicon that turns up in retro systems (custom co-processors, DSPs bundled
  into later-model expansions) that no shipped Ghidra processor spec covers.
- **Ghidra Server / collaborative projects** — this course is single-user
  throughout; team-based shared-project workflows (checkouts, merges,
  concurrent annotation) are a distinct topic.
- **Firmware RE (ARM/MIPS)** as a natural next step after 8/16-bit retro
  systems, for readers who want to carry these skills into modern embedded
  targets.
- **Malware analysis fundamentals**, including safe sandboxing — only
  relevant if your interest extends beyond retro-platform RE into
  security-research-flavored work.
- **Importing proprietary/undocumented loader formats** — this course
  repeatedly hits "no native or reliably-maintained Ghidra loader exists"
  (Hunk, PRG/TOS, C64 PRG/CRT) and works around it with manual Raw Binary
  imports; a follow-on module could instead teach *writing* a Ghidra
  `Loader` extension, using one of these formats as the worked example.
