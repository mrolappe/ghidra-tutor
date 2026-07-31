# Exercise: Typical Amiga Copy-Protection Patterns

Covers
[`05-copy-protection-patterns.md`](../../05-copy-protection-patterns.md).
No sample binary — this guide is about recognizing *shapes* in disassembly,
not hands-on RE of real (copyrighted) protected disks, so this exercise
works from three short, invented pseudo-disassembly snippets instead. None
of these are real protection code; they're written to exhibit one pattern
each.

## Snippets

**Snippet A**
```
    move.l  #$dff008,a0        ; CIA/timer-ish address, illustrative only
    move.w  (a0),d0            ; read timer value #1
    bsr     read_sector
    move.w  (a0),d1            ; read timer value #2
    sub.w   d0,d1
    cmp.w   #threshold,d1
    blt     protection_fail
```

**Snippet B**
```
check_keydisk:
    bsr     read_serial_from_disk    ; returns 0 on failure, else a 32-bit serial
    move.l  d0,d3
    ; NOTE: no branch here at all
    add.l   d3,checksum_table(pc,d3.w)
    bsr     continue_game_init
```

**Snippet C**
```
decrypt_loop:
    move.b  (a1)+,d0
    eor.b   d2,d0
    move.b  d0,(a0)+           ; a0 points INSIDE this function's own code hunk
    dbra    d1,decrypt_loop
    jmp     (a0)                ; jump into the just-decrypted bytes
```

## Tasks

1. Match each snippet to one pattern from the guide (timing-based check,
   keydisk/serial-number scheme, or anti-disassembly obfuscation) and
   justify the match using specifics from the snippet, not just vibes.
2. For Snippet A: if you patched `blt protection_fail` into an
   unconditional branch around the failure case, would the protection be
   defeated? What would the *real* Rob-Northen-style version of this check
   (per the guide) most likely be comparing, that this simplified snippet
   glosses over?
3. For Snippet B: explain specifically why patching `check_keydisk` to
   always return a fixed non-zero value in `D0` is *not* automatically
   equivalent to defeating the protection, even though the routine "looks
   passed."
4. For Snippet C: name the two separate red flags in this snippet that
   would make you suspect anti-disassembly/self-modifying code even before
   you fully understood what it decrypts.

**Check yourself:** the guide's "trap-door bootstrap loader" pattern isn't
represented by any of the three snippets above — where in a real Amiga
disk image would you have to look to find that pattern, and why wouldn't
it show up in a Ghidra import of the main program executable at all?
