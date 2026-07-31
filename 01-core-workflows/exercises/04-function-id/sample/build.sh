#!/bin/sh
# Builds two independent driver binaries that both #include the same lib.c,
# so checksum()/clamp() compile to identical bytes in each even though the
# surrounding main()/report() differ. That's what lets a FID database built
# from reference.bin recognize the same two functions inside target.bin.
set -e
cd "$(dirname "$0")"
cc -O0 -o reference.bin reference.c
cc -O0 -o target.bin target.c
strip reference.bin target.bin
echo "Built reference.bin and target.bin"
