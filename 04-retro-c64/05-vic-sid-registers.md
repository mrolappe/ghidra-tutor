# VIC-II & SID Registers

Just as raw `$dff0xx` addresses were the strongest "this is hardware-
banging code" signal on Amiga
(`02-retro-amiga/04-custom-chip-registers.md`), raw `$d0xx`/`$d4xx`
addresses play the identical role on the C64: no OS call involved, the
chip is being poked directly. Both register blocks sit inside the I/O
view of `$D000`–`$DFFF` covered in [memory map & bank
switching](02-memory-map-bank-switching.md) — visible only when `CHAREN=1`
banks I/O in over Character ROM.

## VIC-II: $D000–$D3FF (graphics)

Full register set, `$D000`–`$D02E`, verbatim from c64-wiki.com's
"Page_208-211" register table (byte-level field breakdown, not just the
block's outer address range):

| Address | Name | Contents |
|---|---|---|
| `$D000`–`$D00F` | `M0X`/`M0Y` … `M7X`/`M7Y` | Sprite 0–7 X/Y coordinates (one byte pair each) |
| `$D010` | `MxX8` | MSBs of the 8 sprite X coordinates (9-bit X range) |
| `$D011` | Control register 1 | `RST8`, `ECM`, `BMM`, `DEN`, `RSEL`, `YSCROLL` |
| `$D012` | `RASTER` | current raster line (read) / raster IRQ compare line (write) |
| `$D013`/`$D014` | `LPX`/`LPY` | light pen X/Y |
| `$D015` | `MxE` | sprite enable bits, one per sprite |
| `$D016` | Control register 2 | `RES`, `MCM`, `CSEL`, `XSCROLL` |
| `$D017` | `MxYE` | sprite Y-expansion (double height) bits |
| `$D018` | Memory pointers | `VM13`-`VM10` (screen memory base), `CB13`-`CB11` (character/bitmap memory base) |
| `$D019` | Interrupt register | latched interrupt sources: `ILP`, `IMMC`, `IMBC`, `IRST` |
| `$D01A` | Interrupt enable | which of the above can trigger an IRQ: `ELP`, `EMMC`, `EMBC`, `ERST` |
| `$D01B` | `MxDP` | sprite-to-background priority bits |
| `$D01C` | `MxMC` | sprite multicolor-mode bits |
| `$D01D` | `MxXE` | sprite X-expansion (double width) bits |
| `$D01E` | `MxM` | sprite-sprite collision (read, clear-on-read) |
| `$D01F` | `MxD` | sprite-data collision (read, clear-on-read) |
| `$D020` | `EC` | border color |
| `$D021`–`$D024` | `B0C`–`B3C` | background colors 0–3 |
| `$D025`/`$D026` | `MM0`/`MM1` | sprite multicolor registers (shared across all sprites in multicolor mode) |
| `$D027`–`$D02E` | `MxC` | sprite 0–7 individual color |

Beyond `$D02E`, the VIC-II's internal registers are exhausted; the block
repeats (mirrors) up to `$D3FF` on real hardware, which is itself worth
knowing if you see code reading, say, `$D030` and expect it to mean
something distinct — it's the same register set repeating, not new
functionality (the later 8500/8580-era "$D030" VIC-IIe key-color register
found on the C128 doesn't apply to plain C64 hardware).

Sprite pixel data itself isn't in this register block at all — sprites
point *into* ordinary RAM (screen-memory-relative pointers, per c64-wiki's
"Memory addresses of the VIC-II" section), so recognizing a sprite means
recognizing the *pointer* convention, not a fixed address range.

## SID: $D400–$D41C (sound)

Three independent voices plus one shared filter/volume section, source:
c64-wiki.com, "SID" register table:

| Address | Voice 1 | Voice 2 | Voice 3 |
|---|---|---|---|
| frequency (lo/hi) | `$D400`/`$D401` | `$D407`/`$D408` | `$D40E`/`$D40F` |
| pulse width (lo/hi) | `$D402`/`$D403` | `$D409`/`$D40A` | `$D410`/`$D411` |
| control register | `$D404` | `$D40B` | `$D412` |
| attack/decay | `$D405` | `$D40C` | `$D413` |
| sustain/release | `$D406` | `$D40D` | `$D414` |

Each voice's **control register** shares one bit layout: bit 0 `GATE`
(start/stop the envelope), bit 1 `SYNC`, bit 2 `RING MOD` (with the
*previous* voice, wrapping — voice 1 syncs/rings with voice 3), bit 3
`TEST`, bits 4–7 waveform select (`TRIANGLE`/`SAWTOOTH`/`PULSE`/`NOISE`).

Shared registers, after the three voice blocks:

| Address | Contents |
|---|---|
| `$D415`/`$D416` | filter cutoff frequency (11-bit, split lo/hi) |
| `$D417` | filter resonance + routing (which voices/external input pass through the filter) |
| `$D418` | filter mode + main volume |

Recognition shortcut: any `$D404`-style control-register write immediately
preceded by frequency/pulse-width/ADSR writes to the *same voice's* other
registers is initializing one sound effect or note — a very consistent,
easy-to-spot pattern once you know the five-register-per-voice layout
above.

---

**Self-check:** disassembly writes to `$D400`, `$D401`, then `$D404` — is
this graphics or sound code, and what's it doing? → `$D4xx` is SID, not
VIC-II. `$D400`/`$D401` set voice 1's frequency (low/high byte), and
`$D404` is voice 1's control register — this is the start of playing a
note or sound effect on voice 1 (the `$D404` write's low nibble selects
the waveform and, if bit 0 is set, starts the envelope via `GATE`).
