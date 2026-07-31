# Solution: Custom Chip Registers (Agnus/Denise/Paula)

1. The three displacements are `$096`, `$0a8`, `$09a`.
2. `$096` → `DMACON` (write), owned jointly by Agnus/Denise/Paula.
   `$0a8` → `AUD0VOL` (write), owned by Paula. `$09a` → `INTENA` (write),
   owned by Paula.
3. `DMACON`'s read-side register is `DMACONR` at `$002`. If this program
   later read the current DMA state, you'd expect a `move.w $002(a0),Dn`
   (or similar) reading from that separate address — per the guide,
   `DMACON`/`DMACONR` is exactly the kind of write/read address pair where
   "reading and writing the same register at two different offsets" is
   normal, not a disassembly error.
4. Normal, not suspicious. `DMACON`, like `INTENA`/`INTREQ`, uses a
   **set/clear** write convention rather than a plain read-modify-write
   register: per the Amiga Hardware Reference Manual, bit 15 of the
   written word is a `SET/CLR` control bit — `1` means "set the bits
   below that are also `1`", `0` means "clear them" — so a single write
   like `$8200` (bit 15 `SET/CLR=1`, bit 9 `DMAEN=1`) unambiguously means
   "turn DMA on" without ever needing to read the register first to
   preserve unrelated bits. Code that only ever writes these registers,
   never reads them, is the expected shape, not a sign of missing logic.

**Check yourself — answer:** by the same set/clear convention, the top bit
of `$c020` (`$8000`, bit 15) being `1` means this write is a **set**
operation (turning bits on), not a clear — so even without knowing which
specific bits `$0020` (bit 5) controls, you can tell this instruction is
*enabling* something, not disabling it. (Historically, when disassembling
unfamiliar Amiga hardware-banging code, checking bit 15 first — set vs.
clear — is a cheap way to get the direction of an effect before you've
looked up which exact bit does what.)
