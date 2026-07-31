#!/bin/sh
# Builds sample.bin from sample.c and strips local symbols, so Ghidra sees it
# the way it would see any unfamiliar binary (FUN_..., param_1, ... instead of
# the real names) rather than a program that still carries its own answer key.
#
# Needs a C compiler (cc/gcc/clang) and strip — both present by default on
# macOS (Xcode Command Line Tools) and any mainstream Linux distro. On
# Windows, use WSL or substitute MinGW-w64 (`gcc`) + `strip`.
set -e
cd "$(dirname "$0")"
cc -O0 -o sample.bin sample.c
strip sample.bin
echo "Built sample.bin"
