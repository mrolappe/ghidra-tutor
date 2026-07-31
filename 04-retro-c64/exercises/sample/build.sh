#!/bin/sh
# Requires cc65 (cl65 on PATH) -- not installed in the environment these
# exercises were written in, so this script is untested; sanity-check its
# output before relying on it. Get it from https://cc65.github.io/ or a
# package manager (e.g. `brew install cc65`).
#
# cl65 defaults to the C64 target and, with the c64-asm.cfg linker config
# (meant for assembler programmers who don't want the C runtime), builds a
# real C64 PRG in one step -- no separate ca65+ld65 call needed for a single
# source file, the same single-step shape 03-retro-atari-st's vasmm68k_mot
# -Ftos build had, confirmed here via cc65's own C64 platform docs
# (c64.html section 4.2), not assumed from that naming pattern.
#
# -u __EXEHDR__ forces linking the small BASIC "SYS" stub module, so the
# resulting sample.prg starts with a one-line tokenized BASIC program
# ("SYS <entry>") and can be started with LOAD+RUN -- the standard PRG
# bootstrap convention described in 04-prg-cartridge-formats.md. Without
# -u __EXEHDR__, c64-asm.cfg still prepends the 2-byte $0801 load address,
# just without the BASIC stub in front of the code.
set -e
cd "$(dirname "$0")"

cl65 -o sample.prg -t c64 -C c64-asm.cfg -u __EXEHDR__ sample.s
