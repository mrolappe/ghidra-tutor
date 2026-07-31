# PRG & Cartridge (CRT) Formats

Two ways a C64 program reaches memory: loaded from disk/tape as a `.PRG`
file, or present at power-on as a plugged-in cartridge. Both are far
simpler than the Amiga's Hunk format (`02-retro-amiga/02-hunk-executable-format.md`)
or the Atari ST's PRG/TOS header (`03-retro-atari-st/03-prg-tos-executable-format.md`)
— no block sequence, no relocation fixup stream in the common case — but
each has its own header worth knowing before you import one.

## PRG: a 2-byte load address, then raw bytes

The entire format is: **two bytes, little-endian, giving the load
address, followed by the file's remaining bytes loaded verbatim starting
at that address.** No length field, no magic number, no segments — the
file's own size on disk *is* the data length. Source: c64-wiki.com,
"LOAD," and cross-confirmed by the Just Solve the File Format Problem
wiki's Commodore-binary-executable entry — both describe the identical
two-byte little-endian header.

The load address is conventionally `$0801` — the fixed start of BASIC
program storage on an unexpanded C64 (see the [memory
map](02-memory-map-bank-switching.md)'s `$0800`–`$9FFF` "free BASIC
program storage" row) — because the standard way to start a machine-
language program from BASIC is a one-line tokenized BASIC stub like `10
SYS 2064` immediately followed by the ML code, so that `LOAD
"PROGRAM",8,1` (the `,1` tells the KERNAL to honor the file's own load
address instead of always using `$0801`) followed by `RUN` boots straight
into the ML payload via `SYS`.

Importing into Ghidra: **Raw Binary**, base address set to the value of
the first two (little-endian) bytes, with those two header bytes
themselves excluded from the loaded image (they aren't part of the
program's own address space).

## CRT: cartridge images (an emulator-era format, not the ROM chip's own layout)

Real C64 cartridges are physical ROM chips with no on-chip header of their
own — `.CRT` is a container format introduced by the CCS64 emulator to
package a cartridge's ROM contents plus the hardware-configuration
metadata (which memory range each chip occupies, how `GAME`/`EXROM` should
be driven) that a real cartridge port would otherwise convey electrically.
Source: VICE Emulator Manual, §17.14, "The CRT cartridge image format."

### 16-byte file header

Verified directly against VICE's own documented example hex dump (a
sample "Attack Of The Mutant Camels" 8K cartridge) rather than taken on
faith — the field values below are read straight off that dump:

| Offset | Size | Field | Example value | Meaning |
|---|---|---|---|---|
| `$0000` | 16 bytes | signature | `"C64 CARTRIDGE  "` | space-padded; also used for C128/CBM2/VIC20/PLUS4 variants |
| `$0010` | LONG (hi/lo) | header length | `$00000040` | offset where the first `CHIP` packet begins; `$40` is the standard/minimum value |
| `$0014` | WORD (hi/lo) | cartridge version | `$0100` | "1.00" |
| `$0016` | WORD (hi/lo) | hardware type | `$0000` | `0` = generic 8/16K cartridge |
| `$0018` | BYTE | `EXROM` line state | `$00` | expansion-port control line, combines with bank-switching's `GAME`/`LORAM`/`HIRAM`/`CHAREN` (see [memory map & bank switching](02-memory-map-bank-switching.md)) |
| `$0019` | BYTE | `GAME` line state | `$01` | |
| `$001A`–`$001F` | 6 bytes | reserved | `0` | |
| `$0020`–`$003F` | 32 bytes | cartridge name | `"ATTACK OF THE MUTANT CAMELS"` | zero-padded ASCII |

### CHIP packets: the actual ROM data

One or more `CHIP` packets follow the header, each self-describing where
its ROM image belongs in the C64's address space:

| Offset (within packet) | Size | Field | Meaning |
|---|---|---|---|
| `+$00` | 4 bytes | signature | literal `"CHIP"` |
| `+$04` | LONG (hi/lo) | total packet length | ROM image size + `$10` (this header) |
| `+$08` | WORD (hi/lo) | chip type | `0`=ROM, `1`=RAM, `2`=Flash ROM, `3`=EEPROM |
| `+$0A` | WORD (hi/lo) | bank number | `0` for a plain (non-banked) cartridge |
| `+$0C` | WORD (hi/lo) | load address | where this ROM image goes in C64 address space, e.g. `$8000` |
| `+$0E` | WORD (hi/lo) | ROM image size | e.g. `$2000` (8192 bytes) |
| `+$10` | *n* bytes | ROM data | the actual chip contents |

For a "generic" (type-0) cartridge specifically: `ROML` (low ROM) always
loads at `$8000`; `ROMH` (high ROM, if present) loads at either `$A000` or
`$E000` depending on the `GAME`/`EXROM` state recorded in the file header
— directly tying back into the bank-switching mode table in the previous
guide. Source: same VICE manual section, "C64 Cartridge Specifics."

## No native Ghidra loader for either format

Checked the same way every prior retro module checked its platform's
loader situation — this time against the shipped **binaries** rather than
source (the public Ghidra distribution ships compiled `.jar`s for its
built-in loaders, not their `.java` source): every `Loader`-family class
inside `Ghidra/Features/Base/lib/Base.jar` was listed (`unzip -l`, filtered
to `opinion/*Loader.class`), and every `.jar` across the whole
distribution was searched for any class name matching `c64`, `commodore`,
`prg`, or `cartridge`. **Zero hits** — no PRG loader, no CRT/cartridge
loader, built into stock Ghidra 12.1.2. There's also no `.opinion` file in
`Ghidra/Processors/6502/` at all, meaning the 6502 language isn't
pre-wired to any particular loader the way `68000.opinion` pairs the
68000 with ELF/PEF/a.out.

### Community options — checked, and both come with real caveats

Two GitHub projects turned up, neither in the same "actively maintained,
version-pinned release" shape the Amiga/Atari modules found:

- **`jamesham/ghidra-commodore`** — includes a `CommodoreLoader` Java
  extension with an actual `CommodoreCartridgeLoader` class (handles
  `.CRT`, header fields matching the table above). Last commit
  2022-01-03, **no tagged releases at all** (source-only, would need a
  manual Eclipse/Gradle build against a matching GhidraDev version) — and
  it covers cartridges only, **not PRG files**.
- **`tom-seddon/Ghidra6502`** — improves 6502 CPU support (a refined
  language description, a "6502 Constant Reference Analyzer" that handles
  indexed addressing better than Ghidra's default). Not a format loader at
  all — it changes how the *CPU* is disassembled, not how a file gets
  imported. Last pushed 2020-07-17, install is "import the Eclipse project
  and run Ghidra from inside Eclipse" (no packaged extension).

**Practical takeaway**: for PRG files, plan on manual **Raw Binary**
import at the header-specified load address (above) — there's no loader to
do it for you, and the format is simple enough that this is genuinely the
path of least resistance. For CRT/cartridge work, `ghidra-commodore`'s
`CommodoreLoader` is worth trying if you're willing to build it yourself,
but treat it as unverified/experimental rather than a turnkey extension —
manually splitting out each `CHIP` packet's ROM data to its documented
load address (per the table above) is the fallback either way.

---

**Self-check:** a `.PRG` file's first two bytes on disk are `01 08` — what
address does this program load at, and why is that value specifically
common? → Little-endian, so the load address is `$0801` — the standard
start of free BASIC program storage, which is why nearly every PRG you'll
encounter uses it: it lets a BASIC `SYS` stub and the following ML code
share one seamless load.
