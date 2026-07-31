# Solution: 68000/TOS Differences From Amiga

1. `move.l 4(sp),a0` loads `A0` with the pointer GEMDOS pushed onto the
   stack at process-start time: the address of this process's own 256-byte
   **basepage**. There's no fixed absolute address to scan for because TOS
   hands each process its *own* basepage at a process-specific address —
   unlike Amiga's `ExecBase`, which is the same system-wide value (`$4`) for
   every running program.
2. `$0c(a0)` is `p_tlen` (length of the TEXT segment); `$18(a0)` is
   `p_bbase` (base address of the BSS segment).
3. This is `Mshrink()` (GEMDOS opcode `0x4A`, via `TRAP #1`). It makes sense
   here because GEMDOS hands a fresh process the *entire remaining TPA*, not
   a right-sized block — a well-behaved program computes what it actually
   needs (which is exactly what the two basepage-field reads just did) and
   gives the rest back immediately with `Mshrink()`, typically as one of the
   first things it does after startup.
4. `move.w #$20,-(sp)` / `trap #1` is `Super()` (GEMDOS opcode `0x20`). Per
   the guide, this is the RE signal that the code is requesting supervisor
   mode — expect the instructions right after it to touch hardware
   registers or low memory (`$0`–`$7FF`) directly, since user mode isn't
   allowed to.
5. On an Amiga Hunk binary you'd scan for `move.l 4.w,a6` (or `4.w,aN` for
   any address register) — a read of the fixed absolute address `4`, not a
   stack-relative read. It's a fundamentally different pattern, not just a
   different address, because the Amiga version is a *global, static*
   lookup (same instruction bytes work for every program, every run), while
   the Atari version is *per-process* (the actual basepage address differs
   every time GEMDOS loads the program) — you're pattern-matching the
   addressing mode and stack offset, not a literal constant.

**Check yourself — answer:** look for a read of `4(sp)` (stack-relative,
Atari basepage) vs. `4.w` or `4,A6`-style (absolute, Amiga `ExecBase`) in
the first few instructions after entry. Both platforms establish their
"reach the system" pointer in the first handful of instructions, so this
check resolves the question almost immediately without needing to look at
the file header at all.
