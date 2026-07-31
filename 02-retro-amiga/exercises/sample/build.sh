#!/bin/sh
# Requires vasm (vasmm68k_mot) and vlink on PATH — not installed in the
# environment these exercises were written in, so this script is untested;
# sanity-check its output before relying on it. Get both from
# http://sun.hasenbraten.de/vasm/ and http://sun.hasenbraten.de/vlink/
# (build the m68k target of vasm: `make CPU=m68k SYNTAX=mot`).
set -e
cd "$(dirname "$0")"

# Flat binary — direct "Raw Binary" import into Ghidra, used by exercises
# 01 (68000 recap), 03 (exec.library pattern), 04 (custom chip registers).
vasmm68k_mot -Fbin -o sample.bin sample.s

# Amiga Hunk executable — used by exercise 02 to walk the real block
# structure, and optionally by exercise 03 to compare a loader-resolved
# import against the raw one.
vasmm68k_mot -Fhunk -o sample.o sample.s
vlink -bamigahunk -o sample.hunk sample.o
