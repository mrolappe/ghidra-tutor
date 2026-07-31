# Typical Amiga Copy-Protection Patterns

Recognition, not a how-to: these are well-documented historical patterns
worth spotting in disassembly, sourced from Amiga preservation/history
material rather than cracking guides. Understanding *what a pattern looks
like* is a normal RE skill — comes up just as often in legitimate
compatibility or preservation work as anything else.

## Non-standard track formats

Protected disks often included at least one track written in a format a
standard drive could *read* correctly but a standard disk-copy program would
reproduce *incorrectly*: "The method used ... was to use a format that the
Amiga drive could read without error, but was unable to write. [This]
normally involved changing the bitcell size of outputted bytes written to the
track." Source: Rob Northen (creator of the widely-licensed "Copylock"
protection) interviewed on Codetapper's Amiga preservation site.

## Timing-based checks

A close cousin: code that reads two sectors and compares how *long* each read
took, rather than checking their content — "I was able to detect this special
sector by comparing the times to read in both types of sector. ... the 'slow'
sector had to take at least 15% longer to read ... or it failed the
protection test." (Same source.) This maps naturally onto the Amiga's CIA
(8520) chip timers — AmigaOS documents each CIA as providing two general
interval timers "intended ... for high performance timing applications"
(MIDI/SMPTE clocking, normally) — repurposed here to measure disk-read
duration instead. **In Ghidra**, look for code that reads a CIA timer
register, performs a floppy read, reads the timer again, and branches on the
delta against a threshold constant — that shape is the tell, regardless of
the exact registers used.

## Keydisk / serial-number schemes

Rather than one hard-coded pass/fail check, some protections issued each
licensee a uniquely-serialized keydisk, and the check routine "would either
return 0 if the protection failed or a 32-bit serial number of the keydisk" —
with the explicit design advice to *not* branch on that result directly, but
to "incorporate somehow the number into their own data, which would be used
later in the game." **In Ghidra**, this means the interesting artifact isn't
a conditional jump right after the check — it's the returned value flowing
into some later, seemingly-unrelated computation (a checksum, a table index,
a decryption key). A protection defeated this way survives naive
patch-the-branch cracking, so don't assume the check-and-branch is where the
logic actually lives.

## Anti-disassembly obfuscation

The same historical schemes commonly wrapped the check itself in
self-modifying code and XOR-based obfuscation, specifically to resist static
analysis. **Signals to watch for**: a function whose own bytes are written to
at runtime (a store instruction targeting an address inside the current code
hunk), or a loop computing a running checksum/XOR over a code or data hunk
and comparing it to a constant — either is a strong hint you're looking at a
protection or anti-tamper routine rather than ordinary program logic, even
before you understand what it's protecting.

## Trap-door bootstrap loaders

A floppy's boot block can contain custom code that runs *before*
AmigaDOS/Kickstart hands off to the normal filesystem loader — letting a
protected disk run its own bespoke loader (check the special track, then
decrypt and load the real program) instead of a standard [Hunk-format
load](02-hunk-executable-format.md). This is the general mechanism behind
"trap door" protections. One frequently-repeated elaboration — that
Copylock specifically used the 68000's trace-exception mode to decrypt only
one or two instructions of the real program into memory at a time, so
plaintext code was never fully resident — comes from a Wikipedia article that
flags itself as relying on a single source; treat it as a plausible,
widely-repeated description rather than an independently-confirmed fact.

---

**Self-check:** you find a function that returns a 32-bit value from a
protection check, and the very next instruction is an unconditional jump into
unrelated-looking game logic (no compare, no branch) — is this protection
already defeated by NOPing something, or does it need more care? → More
care: this is exactly the "mix the result into later data instead of
branching on it" pattern — the returned value likely feeds into a checksum,
key, or table index further down, so a naive "find the branch and flip it"
approach won't work.
