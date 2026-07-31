# 03 — Retro: Atari ST

Second retro-platform module, same 68000 CPU as `02-retro-amiga` but a
different OS (TOS/GEMDOS instead of AmigaOS). This module builds directly
on the Amiga module rather than repeating shared ground — the 68000 recap
(`02-retro-amiga/01-68000-recap.md`) isn't restated here, only what's
different for TOS.

```mermaid
flowchart TB
    subgraph Header["Header — 28 bytes (0x00–0x1B)"]
        M["PRG_magic 0x601A (WORD)"]
        T["PRG_tsize (LONG)"]
        D["PRG_dsize (LONG)"]
        B["PRG_bsize (LONG)"]
        S["PRG_ssize (LONG)"]
        R["PRG_res1 (LONG)"]
        F["PRGFLAGS (LONG)"]
        A["ABSFLAG (WORD)"]
    end
    Header --> TX["TEXT segment @ 0x1C\n(entry point: byte 0)"]
    TX --> DA["DATA segment @ tsize+0x1C"]
    DA --> SY["Symbol table @ tsize+dsize+0x1C\n(vendor-specific layout)"]
    SY --> FO["Fixup offset @ tsize+dsize+ssize+0x1C\n(one LONG, 0 = none)"]
    FO --> FI["Fixup byte stream @ tsize+dsize+ssize+0x20"]
```

Field-by-field detail, the `PRGFLAGS` bit table, and the fixup-stream
encoding are in [PRG/TOS executable format](03-prg-tos-executable-format.md).

1. [68000/TOS differences from Amiga](01-amiga-atari-differences.md)
2. [GEMDOS/BIOS/XBIOS call recognition](02-gemdos-bios-xbios-calls.md)
3. [PRG/TOS executable format](03-prg-tos-executable-format.md)

Printable one-page reference: [cheatsheet-print.md](cheatsheet-print.md).

Facts in these guides are checked against The Atari Compendium, FreeMiNT's
`tos.hyp` documentation, and Ghidra 12.1.2's own source — see
`RESEARCH-NOTES.md` for full sourcing, the Compendium's distribution
caveat, and an "Unresolved" list of anything that couldn't be pinned to a
primary source.
