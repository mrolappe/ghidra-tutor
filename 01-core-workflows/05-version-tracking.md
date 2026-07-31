# Version Tracking Basics

Version Tracking (VT) carries your analysis work (labels, comments, types,
signatures) from a binary you've already analyzed forward onto a new
version of the same binary — or finds known code inside an unrelated
binary. It's a separate tool with its own concepts, distinct from anything
in the base CodeBrowser.

## Core concepts

- **Session** — created by running a matching algorithm (a **correlator**)
  against two programs; stored in the Ghidra Project Window; records the
  history of work done in it (accepted matches, applied markup); can be
  reopened and extended later with additional correlator runs.
- **Source / Destination program** — the source is the already-analyzed
  program whose markup you want to reuse; the destination is the new
  program receiving it.
- **Association** — a pairing between an item (function or data) in the
  source and one in the destination, suggested by a correlator. Multiple
  candidate associations for the same item are **conflicting**; accepting
  one **blocks** the conflicting others (VT only allows one-to-one
  mappings).
- **Match** — an association plus a similarity score assigned by the
  correlator that found it. Lives in the **Matches Table**. Accepting a
  match blocks its conflicts; applying markup for a match auto-accepts it.
- **Implied Match** — when you accept a *function* match, VT automatically
  proposes matches for the functions *called by* both sides of that match —
  propagating confidence outward from a known-good anchor.
- **Markup Item** — a specific annotation (comment, label, data type,
  parameter/variable name, function signature) on the source side that can
  be ported over to the matched destination location.
- **Correlator** — the matching algorithm itself. Different correlators use
  different evidence (raw bytes, instruction mnemonics, symbol names, data
  references, prior match results).

Source:
`Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/Version_Tracking_Intro.html`.

## Starting a session

Open the Version Tracking Tool (the blue-footprints icon in the Ghidra
Project Window / Tool Chest). Either:

- Drag two programs onto it (or one, then be prompted for the second) — you
  get a **swap** button in case source/destination end up backwards, then
  the wizard's **New Version Tracking Session** panel to name the session
  and folder; or
- Use the **Create Session** action from within an already-open VT tool.

The wizard's **Preconditions** panel then runs a set of "validators" —
sanity checks comparing the two programs (function counts, analysis
completeness, memory-map similarity, non-returning-function counts, off-cut
reference counts) — before you proceed. Fixing flagged problems first
matters: VT results on poorly-analyzed binaries are explicitly not
guaranteed complete or correct. Preparation checklist from the official
class notes: both binaries should have **similar memory maps**, be **mostly
disassembled correctly** (watch for data misidentified as code, red X
errors, off-cut references), and have **functions created correctly** with
**similar calling conventions** — this connects directly to the
[decompiler-tuning guide](02-decompiler-tuning.md): a wrong calling
convention on one side is exactly the kind of thing that throws off
matching.

Once a session is open, VT launches **two Code Browsers** (source and
destination, each a full CodeBrowser plus VT-specific plugins) and the main
session window with the Matches and Markup Items tables.

Sources:
`Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_Wizard.html`,
`VT_Tool.html`; `GhidraDocs/GhidraClass/Intermediate/VersionTracking.html`
(official class notes — independently confirms the "blue footprints" launch
icon).

## Correlators

Run via the **green plus** icon in the session window (launches the
wizard's Correlation Algorithm panel), which supports running more than one
correlator into the same session over time. Shipped correlators:

**Data Match**: Exact Data Match, Duplicate Data Match, Similar Data Match.

**Function Match**: Exact Function Bytes Match, Exact Function Instructions
Match, Duplicate Function Match, Exact Function Mnemonics Match, Legacy
Import Correlator.

**Symbol Name Match**: Exact Symbol Name Match, Duplicate Exact Symbol Name
Match, Similar Symbol Name Match.

**Reference correlators** (use *existing* matches to find more): Data
Reference Correlator, Function Reference Correlator, Combined Function and
Data Reference Correlator.

Plus the internal **Implied Correlator** (generates Implied Matches, see
above) and **Manual Match Correlator** (for matches you create by hand).

Source:
`Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_Correlators.html`.

## Recommended workflow

Run the **exact** correlators first — Exact Data Match, Exact Function
Bytes Match, Exact Function Instructions Match — since their matches are by
construction unique and correct, and their markup lines up byte-for-byte.
Select all rows in the Matches table with **Ctrl+A**, then click **Apply
Markup** to accept and apply everything at once. Only after exhausting exact
matches should you move to fuzzier correlators (Similar Data/Symbol Name,
Reference correlators) that need individual review — the Matches table's
filter panel (by correlator, match type, accepted/available) helps triage
those.

Source:
`Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_Workflow.html`.

## Automatic Version Tracking

A one-click alternative: the **Automatic Version Tracking** action runs a
fixed, conservative sequence of correlators (Exact Symbol Name → Exact Data
→ Exact Function Bytes → Exact Function Instructions → Exact Function
Mnemonics → Duplicate Function Instructions → one of the reference
correlators), auto-creating and auto-accepting the most confident matches
and applying their markup, with Implied Match creation/application
controlled by options under `Edit → Tool Options → Version Tracking → Auto
Version Tracking`. It deliberately doesn't try to match everything — it
trades completeness for a low false-positive rate.

Source:
`Ghidra/Features/VersionTracking/src/main/help/help/topics/VersionTrackingPlugin/VT_AutoVT.html`.

---

**Self-check:** you've just accepted a function match with high confidence
— what does VT do automatically as a result, beyond marking that one match
accepted? → It proposes **Implied Matches** for the functions called by both
sides of the accepted match, propagating confidence to their callees.
