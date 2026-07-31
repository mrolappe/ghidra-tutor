#!/bin/sh
# Builds sample.bin from sample.c and strips local symbols, same convention
# as 00-quickstart/exercises/02-first-import-analysis/sample/build.sh.
# Needs a C compiler (cc/gcc/clang) and strip.
set -e
cd "$(dirname "$0")"
cc -O0 -o sample.bin sample.c
strip sample.bin
echo "Built sample.bin"
