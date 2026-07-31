# Solution: exec.library & Kickstart Basics

## Part A

1. `move.l 4.w,a6` loads `A6` with the long-word stored at address `4` —
   the one fixed, always-valid pointer on the whole system, which is
   `SysBase`/`ExecBase`. The `lea`/`moveq` pair sets up the call's
   arguments: `A1` gets a pointer to a library-name string, `D0` gets a
   minimum-version number (`0`, meaning "any version"). `jsr -552(a6)`
   then jumps through the LVO jump table at a fixed negative offset from
   the library base in `A6` — `-552` is `exec.library`'s reserved offset
   for `OpenLibrary`, stable across every Kickstart version even though the
   code it actually jumps to differs release to release.
2. The comment should read something like `-552(A6) = _LVOOpenLibrary` on
   the `jsr`, and following `A1`'s `lea` back to the data hunk shows the
   string `graphics.library`.
3. Two things, together: a small negative constant used as a displacement
   off an address register (`-552(A6)`), immediately preceded by that
   register being loaded from a fixed, unusual source address (`4.w`) —
   not a stack slot, not a struct field computed from a parameter. A
   negative offset off a register that was just loaded from address `4` is
   the specific shape that should make you go check the LVO table, even
   with zero symbols present.

## Part B

4–5. Answers depend on your local Ghidra/extension versions and whether
   the extension zip matched, so there's no single expected screenshot
   here — but the two outcomes to watch for are:
   - **Resolved name appears** (`_LVOOpenLibrary` or similar): confirms the
     extension ships enough NDK `.fd`-derived symbol data on its own to
     resolve well-known LVOs like `OpenLibrary`, without needing this
     specific binary to carry any debug/symbol hunks itself.
   - **Still shows a bare `-552(A6)`**: tells you the extension's *loader*
     (parsing the Hunk blocks, setting up memory) worked, but LVO-name
     resolution is a separate layer on top that either needs the target
     binary's own symbol data, or wasn't triggered — worth checking the
     extension's own docs/issues rather than assuming it's broken, since
     this guide's research pass didn't verify that internal split.

**Check yourself — answer:** trust Part A's manual reading over a
disagreeing loader-resolved name for *this specific* offset — `-552`
matching `OpenLibrary` comes straight from RKM Libraries' own documented
convention (function #92 in the fixed `-(N*6)` scheme, off the four
reserved housekeeping vectors), a primary source. A third-party extension
resolving LVO names is convenient, but it's still trusted-with-verification
tooling, not a primary source on its own — the general rule from
`06-ai-assisted-ghidra` (don't take a tool's output as ground truth
unchecked) applies here too, extension or AI either way.
