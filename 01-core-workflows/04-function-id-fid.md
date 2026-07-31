# Function ID (FID)

Function ID identifies statically-linked library code by hashing function
bodies and looking them up in an indexed database — it's how Ghidra
recognizes, say, a Visual Studio C runtime function inside your binary and
labels it correctly even though there's no symbol for it in the file itself.

## How it works

For each function, Function ID computes two 64-bit hashes over the
function's machine instructions, in address order:

- **full hash** — mnemonic + some addressing-mode info + specific register
  operands, but *not* the specific values of constant operands. Robust
  against relocation/linking differences.
- **specific hash** — everything in the full hash, plus the actual values of
  constant operands that a heuristic determines aren't part of an address.
  Distinguishes closely related variants of the same function.

Matches are further disambiguated using **parent/child** relationships: if
two candidate functions have identical instruction sequences but call
different subfunctions, FID uses the (already-identified) subfunction hash
to tell them apart.

A **Single Match** is applied automatically when: the analyzer narrows to
one function name, the function doesn't already have an imported/user name,
and the match's score exceeds the **instruction count threshold** (an
analyzer option — the score being, roughly, the count of matching
instructions including parent/child contributions). It applies the name as
a symbol, inserts a comment naming the matched library, and adds a
"Function ID Analyzer" bookmark, all tagged "Single Match". If disambiguation
can't get to one name but scores clear the **multiple match threshold**, a
**Multiple Match** is reported instead — several candidate symbols/comments
inserted, tagged "Multiple Matches". Below both thresholds, nothing is
reported (treated as noise).

Ghidra ships with pre-built FID databases for Microsoft Visual Studio
statically-linked runtime/CRT libraries on x86 (split by 32/64-bit and VS
version, each with debug and production variants). FID databases are
processor-specific.

Source:
`Ghidra/Features/FunctionID/src/main/help/help/topics/FunctionID/FunctionID.html`.

## Running it

Function ID runs as one of the standard Auto Analysis analyzers (appears as
"Function ID" in the Auto Analysis Options dialog — see 00-quickstart/02),
or on demand via the **One Shot** analysis menu for an already-analyzed
program. Either way it needs at least one active FID database (see below).

## The Function ID Plug-in — managing and building databases

The FID Plug-in (`FidPlugin`) isn't enabled by default in the standard
CodeBrowser tool; enable it via `File → Configure → Ghidra Core →
FidPlugin`. Once enabled, its actions live under `Tools → Function ID`:

- **Choose active FidDbs...** — toggle which installed databases are
  actually searched (per-user preference; all ship active by default).
- **Create new empty FidDb...** — creates a new `.fidb` database file
  (must be outside the Ghidra install directory, which is treated
  read-only). New databases are attached and active immediately, but empty.
- **Attach existing FidDb...** — attach an existing `.fidb` file; the
  attachment (and active status) persists across sessions.
- **Detach attached FidDb...** — remove a database from use and forget it;
  the databases Ghidra ships with can't be detached, only deactivated via
  "Choose active FidDbs...".
- **Populate FidDb from programs...** — ingest hashes from a set of
  already-analyzed programs in the current project into a writable attached
  database.

### Building your own database

1. Import and fully auto-analyze every program that should contribute to
   the library, all within one Ghidra repository, all sharing the same
   Language ID (processor/endianness/bitness/variant/compiler).
2. Organize them under one project folder (the ingest is recursive, so
   subfolders are fine — but everything for one library must be under one
   root).
3. Run **Populate FidDb from programs...** and fill in: the target FID
   database, a **Library Family Name**, **Library Version**, optional
   **Library Variant** (e.g. compiler settings) and **Base Library** (to
   cross-link parent/child relationships with an already-ingested related
   library), the **Root Folder** of programs to scan, the required
   **Language** ID, and an optional **Common Symbol File** (a list of
   function names to exclude as disambiguating children — reduces false
   positives from ubiquitous helper functions).
4. Ingest produces a summary with statistics and a ranked list of the most
   commonly called functions — useful raw material for building that Common
   Symbol File for next time.

Source:
`Ghidra/Features/FunctionID/src/main/help/help/topics/FunctionID/FunctionIDPlugin.html`.

---

**Self-check:** Function ID reports a Multiple Match instead of a Single
Match on a function you're confident is unique — what two conditions, per
the Single Match rule, could be preventing it from collapsing to one name?
→ Either the analyzer can't narrow candidates to one function name (they
share a base name across library versions/variants), or the function
already carries an imported/user-defined name (Single Match requires the
function have neither).
