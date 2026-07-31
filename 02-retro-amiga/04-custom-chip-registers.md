# Custom Chip Registers (Agnus / Denise / Paula)

The Amiga's graphics/audio/DMA hardware is memory-mapped starting at
`$DFF000` — confirmed directly in the AHRM's own memory map ("`DF F000 - DF
FFFF` Chip registers. See Appendix A and Appendix B"). Recognizing a
`$dff0xx`-style address in disassembly is one of the strongest signals that
you're looking at hardware-banging code rather than ordinary application
logic — no OS call needed, the chips are just poked directly.

## Chip-ownership notation

The AHRM's Appendix B register table tags every register with which chip
owns it: **A**gnus, **D**enise, **P**aula (jointly-owned registers get
combined tags like `AD`), plus `(E)` for registers added or changed by the
later ECS chipset. Source: AHRM Appendix B legend.

## Representative registers

All offsets/labels verbatim from AHRM Appendix B (offset is from `$DFF000`):

| Register | Offset | R/W | Chip | Function |
|---|---|---|---|---|
| `DMACONR` | `$002` | R | A, P | DMA control (+ blitter status) — read |
| `DMACON` | `$096` | W | A, D, P | DMA control — write (clear/set) |
| `INTENAR` | `$01C` | R | P | Interrupt enable bits — read |
| `INTENA` | `$09A` | W | P | Interrupt enable bits — write (clear/set) |
| `INTREQR` | `$01E` | R | P | Interrupt request bits — read |
| `INTREQ` | `$09C` | W | P | Interrupt request bits — write (clear/set) |
| `COP1LCH` / `COP1LCL` | `$080` / `$082` | W | A | Copper first location register (high/low) |
| `COP2LCH` / `COP2LCL` | `$084` / `$086` | W | A | Copper second location register |
| `COPJMP1` / `COPJMP2` | `$088` / `$08A` | strobe | A | Restart Copper at first/second location |
| `BLTCON0` / `BLTCON1` | `$040` / `$042` | W | A | Blitter control registers |
| `BPLCON0` | `$100` | W | A, D | Bitplane control (misc. display bits) |
| `DIWSTRT` / `DIWSTOP` | `$08E` / `$090` | W | A | Display window start/stop position |
| `AUD0LCH` / `AUD0LCL` | `$0A0` / `$0A2` | W | A | Audio channel 0 sample pointer |
| `AUD0LEN` | `$0A4` | W | P | Audio channel 0 length |
| `AUD0PER` | `$0A6` | W | P | Audio channel 0 period |
| `AUD0VOL` | `$0A8` | W | P | Audio channel 0 volume |
| `AUD0DAT` | `$0AA` | W | P | Audio channel 0 data (feeds Paula's DAC) |

Channels 1–3 mirror the `AUD0*` block at `+$10` offsets each
(`AUD1*` at `$0B0`.., `AUD2*` at `$0C0`.., `AUD3*` at `$0D0`..) — not
separately tabulated above, but worth expecting once you recognize the
pattern.

## Read/write asymmetry

Several registers have **separate addresses for reading vs. writing the same
logical state** — `DMACON` (write, `$096`) vs. `DMACONR` (read, `$002`), and
likewise the `INTENA`/`INTENAR` and `INTREQ`/`INTREQR` pairs. Seeing code
read and write "the same register" at two different offsets from `$DFF000`
is expected behavior, not a sign of a disassembly error.

Source for this whole guide: AHRM, "Appendix B: Register Summary, Address
Order".

---

**Self-check:** disassembly reads a word from `$DFF01C` and later writes a
word to `$DFF09A` — are these the same register? → Yes: `$01C` is
`INTENAR` (read) and `$09A` is `INTENA` (write) — the read/write pair for
Paula's interrupt-enable bits, not two unrelated registers.
