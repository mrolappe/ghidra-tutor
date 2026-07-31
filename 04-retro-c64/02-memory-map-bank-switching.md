# Memory Map & Bank Switching

The 6510 can only address 64K (`$0000`–`$FFFF`), but the C64 has RAM,
BASIC ROM, KERNAL ROM, Character ROM, and memory-mapped I/O all wanting
addresses inside that same 64K. The trick — as on most 8-bit micros of the
era — is **bank switching**: several physical chips share the same
address range, and a couple of control bits decide which one the CPU
actually sees at any given moment. This is the single most important
platform fact to internalize before reading C64 disassembly, because it
means **the same address can mean different things at different points in
a program's execution** — something Ghidra's static Listing view has no
way to represent on its own.

## The RAM view (what's "underneath" everything)

| Address | Contents |
|---|---|
| `$0000`–`$00FF` | Zero page |
| `$0100`–`$01FF` | Stack (see [6502/6510 recap](01-6502-6510-recap.md)) |
| `$0200`–`$03FF` | OS/BASIC pointers and buffers |
| `$0400`–`$07FF` | Screen memory (default) |
| `$0800`–`$9FFF` | Free BASIC program storage |
| `$A000`–`$BFFF` | Free ML storage *when switched out from BASIC ROM* |
| `$C000`–`$CFFF` | Free ML storage (never has a ROM overlay) |
| `$D000`–`$DFFF` | Free ML storage *when switched out from Character ROM/I-O* |
| `$E000`–`$FFFF` | Free ML storage *when switched out from KERNAL ROM* |

Source: c64-wiki.com, "Memory Map."

## The ROM view (what can overlay that RAM)

| Address | Contents when banked in |
|---|---|
| `$8000`–`$9FFF` | Cartridge ROM (low) |
| `$A000`–`$BFFF` | BASIC interpreter ROM, or cartridge ROM (high) |
| `$D000`–`$DFFF` | Character generator ROM |
| `$E000`–`$FFFF` | KERNAL ROM, or cartridge ROM (high) |

## The I/O view (what else can appear at $D000–$DFFF)

| Address | Contents |
|---|---|
| `$D000`–`$D3FF` | VIC-II registers |
| `$D400`–`$D7FF` | SID registers |
| `$D800`–`$DBFF` | Color RAM |
| `$DC00`–`$DCFF` | CIA 1 |
| `$DD00`–`$DDFF` | CIA 2 |
| `$DE00`–`$DEFF` | I/O 1 (cartridge expansion) |
| `$DF00`–`$DFFF` | I/O 2 (cartridge expansion) |

So `$D000`–`$DFFF` alone can be *three completely different things*
(Character ROM, RAM, or this I/O block) depending on bank state — see
[VIC-II/SID registers](05-vic-sid-registers.md) for what lives inside the
I/O view specifically.

Sources for all three tables: c64-wiki.com, "Memory Map."

## The control bits: $00 (DDR) and $01 (port register)

This is the 6510-specific I/O port flagged in the previous guide — not
modeled by Ghidra's plain 6502 processor spec, so it just looks like
ordinary zero-page RAM there.

- **`$00`** is the port's **data-direction register**. Bits 0–2 must be
  set to `1` (output) for the corresponding `$01` bits to actually drive
  the bank-switch lines. This is the default state at power-up.
- **`$01`** is the **port register** itself. Its three least-significant
  bits are named control lines:

| Bit | Weight | Name | Effect when high (1, normal) |
|---|---|---|---|
| 0 | 1 | `LORAM` | BASIC ROM banked in at `$A000`–`$BFFF` |
| 1 | 2 | `HIRAM` | KERNAL ROM banked in at `$E000`–`$FFFF` |
| 2 | 4 | `CHAREN` | I/O banked in at `$D000`–`$DFFF` (instead of Character ROM) |

Clearing a bit typically swaps the corresponding ROM/I-O for plain RAM —
"typically," because two more lines (`GAME`/`EXROM`, driven by whatever's
plugged into the expansion port, not by software) combine with these three
to select among **14 distinct memory configurations**, not a simple
per-bit toggle. Source: c64-wiki.com, "Bank Switching" — "Control bits"
and "CPU Control Lines" sections.

### The mode table (no cartridge inserted — GAME=EXROM=1)

The eight combinations of `LORAM`/`HIRAM`/`CHAREN` with no cartridge
present, condensed from c64-wiki's full 32-row PLA table (source: c64-wiki.com,
"Bank Switching," "Optimised Mode Table"):

| LORAM | HIRAM | CHAREN | `$8000`–`$9FFF` | `$A000`–`$BFFF` | `$D000`–`$DFFF` | `$E000`–`$FFFF` |
|---|---|---|---|---|---|---|
| 1 | 1 | 1 | RAM | BASIC ROM | I/O | KERNAL ROM |
| 0 | 1 | 1 | RAM | RAM | I/O | KERNAL ROM |
| 1 | 0 | 1 | RAM | RAM | I/O | RAM |
| 0 | 0 | X | RAM | RAM | RAM | RAM |
| 1 | 1 | 0 | RAM | BASIC ROM | Char ROM | KERNAL ROM |
| 0 | 1 | 0 | RAM | RAM | Char ROM | KERNAL ROM |
| 1 | 0 | 0 | RAM | RAM | Char ROM | RAM |

The top row (`LORAM=HIRAM=CHAREN=1`) is the **default configuration** —
what a freshly reset C64, or a freshly imported binary in Ghidra, should
generally be assumed to reflect unless the code visibly pokes `$01`
first. Source: c64-wiki.com, "Bank Switching," "Mode Table Notes" —
"The default is mode 31 (no cartridge) as all latch bits are logically
high."

### Why this matters for RE, concretely

- Seeing `LDA #$35 / STA $01` (or similar) early in a program is a
  reliable signal that the code is about to bank out KERNAL/BASIC ROM to
  get full RAM at `$A000`–`$FFFF` — common in demos, games, and anything
  that wants the memory those ROMs otherwise occupy.
- Code that reads/writes `$D000`–`$DFFF` only makes sense once you know
  whether `CHAREN` is set at that point — the same address range is VIC-
  II/SID/CIA/Color-RAM I/O in one mode and Character ROM in another.
- Because Ghidra's Listing is a **static** view of one imported binary
  image, it shows one fixed interpretation of every address — it cannot
  show "this becomes RAM after the `STA $01` at offset X." Treat writes to
  `$00`/`$01` as a signal to mentally (or via a comment) track which
  memory configuration is active from that point forward, the same way
  you'd track a segment override in x86 real-mode code.

---

**Self-check:** disassembly shows `LDA #$36`, `STA $01`, and later a `JSR`
to an address in `$A000`–`$BFFF` — is that call going into BASIC ROM or
into RAM? → `$36` = `00110110`; bit 0 (`LORAM`) = 0, bit 1 (`HIRAM`) = 1,
bit 2 (`CHAREN`) = 1. `LORAM=0` means BASIC ROM is banked *out* — the call
targets RAM at `$A000`–`$BFFF`, not the BASIC interpreter.
