# Solution: Typical Amiga Copy-Protection Patterns

1. **A → timing-based check.** Two reads of a timer-like register bracket
   a disk-sector read, and the delta is compared against a threshold —
   exactly the CIA-timer "compare how long the read took" shape from the
   guide, not a content check. **B → keydisk/serial-number scheme.** The
   routine returns a value in `D0` and, notably, there is *no* conditional
   branch on it at all — the value instead flows straight into
   `checksum_table` before continuing, matching the guide's "don't branch
   directly, mix it into later data" description. **C → anti-disassembly
   obfuscation.** A loop XOR-decrypts bytes and writes them into the
   *current* code hunk (self-modifying), then jumps into the freshly
   written bytes — the guide's self-modifying-code/XOR-checksum signal.
2. No — patching the branch only removes *this* observable consequence of
   the check, but per the guide, real Rob-Northen-style protections
   typically check something structural about the media itself (a
   non-standard track's read timing / bitcell format), not a value this
   snippet even models. The simplified snippet glosses over *what*
   `threshold` and the timer actually measure physically; a real check
   would need the actual protected media (or an accurate emulation of its
   timing) to pass honestly — patching the branch gets the code past this
   one check but doesn't tell you whether other, later logic quietly
   depends on the same timing signal.
3. Per the guide's keydisk pattern, the returned serial number is
   deliberately *not* just a pass/fail gate — it's folded into
   `checksum_table` and used later (as a decryption key, a checksum
   input, a table index). A fixed, wrong "always non-zero" value makes
   `check_keydisk` itself look satisfied, but the wrong value is now
   baked into `checksum_table`'s contents, which downstream code
   (`continue_game_init` or whatever reads that table) will use — so the
   protection can still fail later, just somewhere that doesn't obviously
   look like "the protection check," which is exactly the point of
   designing it this way.
4. First: a store instruction (`move.b d0,(a0)+`) whose target address is
   explicitly noted as pointing inside the function's own code hunk — a
   function writing to its own code region is the textbook
   self-modifying-code tell. Second: an `eor.b` (XOR) feeding that store in
   a tight loop against a running value in `d1`/`d2` — a decrypt-then-jump
   shape — followed by `jmp (a0)`, jumping directly into memory the
   function itself just wrote, rather than to a fixed, statically-known
   label. Either alone is suspicious; together they're a strong match for
   the pattern before you've worked out what's actually being decrypted.

**Check yourself — answer:** the disk's **boot block** (track 0, loaded
directly by the Amiga's boot ROM before AmigaDOS/Kickstart hands control to
the normal filesystem loader) — not inside the main program executable at
all. A Ghidra import of the game/program's Hunk executable only sees what
that executable's own hunks contain; a trap-door loader living in the boot
block is a separate, earlier piece of code that runs *before* any
Hunk-format load happens, so it needs to be extracted and analyzed from a
raw disk-image dump of track 0, not found by importing the program file
itself.
