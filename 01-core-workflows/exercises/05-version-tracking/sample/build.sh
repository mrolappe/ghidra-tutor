#!/bin/sh
# Builds v1.bin and v2.bin: two "versions" of the same small program.
# validate() is untouched, format_result() moved but is byte-identical,
# compute() has a changed constant, and bonus() is new in v2 — a deliberate
# mix for exercising exact vs. fuzzy Version Tracking correlators.
set -e
cd "$(dirname "$0")"
cc -O0 -o v1.bin v1.c
cc -O0 -o v2.bin v2.c
strip v1.bin v2.bin
echo "Built v1.bin and v2.bin"
