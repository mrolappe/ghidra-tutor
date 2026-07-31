#!/bin/sh
# Requires vasm (vasmm68k_mot) on PATH — not installed in the environment
# these exercises were written in, so this script is untested; sanity-check
# its output before relying on it. Get it from
# http://sun.hasenbraten.de/vasm/ (build the m68k target:
# `make CPU=m68k SYNTAX=mot`).
#
# Unlike 02-retro-amiga's sample (which needs a separate `vlink -bamigahunk`
# step for a real Hunk executable), vasmm68k_mot can emit a real Atari
# TOS/GEMDOS PRG directly via -Ftos — no linker needed for a single-file
# program like this one (confirmed via a documented vasmm68k_mot invocation,
# not guessed from the Amiga naming pattern).
set -e
cd "$(dirname "$0")"

# Flat binary — direct "Raw Binary" import into Ghidra (no PRG loader exists
# in stock Ghidra 12.1.2 — see 03-prg-tos-executable-format.md), used by
# exercises 01 (basepage pattern) and 02 (GEMDOS call recognition).
vasmm68k_mot -Fbin -o sample.bin sample.s

# Real PRG/TOS executable — used by exercise 03 to walk the genuine 28-byte
# header by hand (od/hex viewer), the same role Phase 6's -bamigahunk build
# played for the Hunk block walk.
vasmm68k_mot -Ftos -nosym -o sample.prg sample.s
