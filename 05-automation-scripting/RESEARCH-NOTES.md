# Research notes — 05-automation-scripting (Phase 11)

Sourced two ways, both against the actual **Ghidra 12.1.2** distribution
installed at `~/ghidra_12.1.2_PUBLIC` on this machine (same pinned release as
every earlier module) — the first module where a real Ghidra install was
available in-session:

1. **Static**: reading shipped files directly — `docs/ChangeHistory.md`,
   `support/analyzeHeadlessREADME.md`, the official
   `docs/GhidraClass/Intermediate/Scripting.html` training-class deck, and
   the `Ghidra/Features/PyGhidra/` module's own `README.md`/`pypkg/README.md`/
   source. Distribution is binary (no bundled `.java` source tree for most
   features, unlike whatever full source checkout earlier modules apparently
   had access to), so citations point to help/doc/changelog files, not
   `KeyBindingData`/`MenuData` source lines — a different sourcing shape from
   00-quickstart/01-core-workflows, closer to Phase 9's `unzip -l`-on-`.jar`
   method.
2. **Live execution** (new for this project): actually ran
   `support/analyzeHeadless` and `support/pyghidraRun -H` against
   `01-core-workflows/exercises/sample/sample.bin` (built via that module's
   own `build.sh` — reused, not rebuilt) with small throwaway test scripts in
   `/tmp`, to confirm CLI behavior that the docs describe but don't show
   verbatim output for. Where a fact below is marked "verified live", it's
   from actual command output on this machine (macOS/AArch64), not just
   docs prose.

---

## 1. Script Manager & Java API

- Script Manager UI (category tree, filterable table, Run/Edit/New/Delete/
  Assign-Key-Binding/Refresh/Help buttons), default script directory
  `<HomeDirectory>/ghidra_scripts`, and the "Edit Script with Eclipse" →
  GhidraDev flow are all from `docs/GhidraClass/Intermediate/Scripting.html`
  (the official Ghidra training-class slide deck, shipped in the
  distribution itself — same content NSA uses to teach this).
- Script metadata tags (`@category`, `@keybinding`, `@menupath`, `@toolbar`)
  and their exact syntax/examples (`@category A.B.C`,
  `@keybinding ctrl alt shift F1`, `@menupath File.Run.My Script`,
  `@toolbar myScriptImage.gif`) — same source. Consistent with
  `01-core-workflows/06-scripting-outlook.md`'s already-sourced summary of
  the same four tags (that file cited
  `GhidraScriptMgrPlugin.htm`/`CheatSheet.html`); this phase adds the
  training deck as a second, independent confirmation.
- `GhidraScript` base class shape (`ask...()`, `create...()`, `find...()`,
  `get...()`, `remove...()`, `runScript()`, `set...()`, `to...()` method
  families) and script-state fields (`currentProgram`, `currentAddress`,
  `currentLocation`, `currentSelection`, `currentHighlight`, `state`,
  `monitor`) — same deck, "Script API"/"Script State" slides.
- Flat API vs. Program API distinction ("Flat" = `GhidraScript`'s own
  methods, broad but not complete, deliberately kept stable across
  versions; "Program" = the full object-oriented `Program`/`Listing`/
  `Function`/... tree, deep but can change release to release) — same
  source.
- GhidraDev Eclipse plugin location confirmed by directory listing:
  `Extensions/Eclipse/GhidraDev/GhidraDev-5.0.1.zip` ships in this
  distribution. Deck's claim that scripts always run from the Script
  Manager even when edited/debugged in Eclipse — same deck, "Running
  Scripts"/"Debugging in Eclipse" slides.
- **Verified live**: a script's `.java` filename is matched against
  **every** search path — the ones from `-scriptPath` *and* every
  distribution-bundled `ghidra_scripts` directory *and* the user's
  `~/ghidra_scripts` — not just the path(s) you pass. A test script named
  `ListFunctions.java` placed in a custom `-scriptPath` directory was
  silently shadowed by Ghidra's own built-in
  `Ghidra/Features/FunctionID/ghidra_scripts/ListFunctions.java` (same
  filename); renaming the test script to something unique
  (`MyListFunctionsScript.java`) fixed it and ran the intended file (log
  line showed the exact resolved path,
  `SCRIPT: /tmp/.../MyListFunctionsScript.java`). Not stated explicitly in
  `analyzeHeadlessREADME.md`'s `-scriptPath` section, which only documents
  what gets searched, not resolution order/collision behavior — this is a
  real gotcha the docs don't spell out. `-postScript`/`-preScript` printed
  the full list of default search directories at startup when run, which
  is where this was caught.

## 2. Python scripting: Jython (legacy) vs. PyGhidra (native CPython 3, the default)

This is the biggest correction to `PLAN.md`'s original framing ("Jython
scripting, Ghidrathon (Python 3) as the modern path") — reality in 12.1.2
has moved past both halves of that description:

- **Jython is no longer built in.** `docs/ChangeHistory.md`: "_Jython_.
  Jython support is now delivered as a Ghidra Extension, which means an
  extra step is required to install it. If Jython is required, the user
  should simply go to __File -> Install Extensions__ ... and check
  __Jython__. The user must restart Ghidra to complete the enablement of
  Jython. (GP-6754)". Confirmed by directory listing:
  `Extensions/Ghidra/ghidra_12.1.2_PUBLIC_20260605_Jython.zip` (53.7 MB) —
  present as an installable extension archive, not unpacked/active by
  default. `support/jythonRun(.bat)` (the old direct-launch script) was
  removed outright per the same changelog file, line 17 of this release's
  entries.
- **"Ghidrathon" isn't a separate thing to recommend anymore — it became
  PyGhidra.** `docs/ChangeHistory.md`: "_Scripting_. Integrated the DoD
  Cyber Crime Center's Pyhidra tool (renamed to PyGhidra) to provide a
  native CPython 3 interface to Ghidra. (GP-4816, Issue #6900)". PyGhidra's
  own `Ghidra/Features/PyGhidra/pypkg/README.md` states the same lineage
  directly: "originally developed by the Department of Defense Cyber Crime
  Center (DC3) under the name 'Pyhidra'". (Ghidrathon, the community
  project the original plan text had in mind, was a *different*,
  separately-maintained JEP-based CPython bridge that predates this
  official integration — not covered here since it's no longer the
  practical modern path once Ghidra ships its own native-CPython bridge.)
- **Default runtime for a `.py` script changed to PyGhidra.**
  `docs/ChangeHistory.md`: "_Scripting_. Python scripts that do not declare
  a `@runtime` metadata comment now default to PyGhidra instead of Jython.
  Jython scripts will need to include the '`@runtime Jython`' script header
  in order to continue running within the Jython environment. (GP-5415,
  Issue #7856)". The general `@runtime` mechanism itself (lets different
  `GhidraScriptProvider`s share the `.py` extension) is GP-4706.
- **Verified live**, three-way, same script logic (list all functions),
  same `sample.bin`:
  - A Java `GhidraScript` via plain `analyzeHeadless -postScript
    MyListFunctionsScript.java` — works, printed 8 functions with
    addresses.
  - A `.py` script with **no** `@runtime` tag via plain `analyzeHeadless
    -postScript MyPyListFunctions.py` — **fails**, exact error: `Ghidra was
    not started with PyGhidra. Python is not available`
    (`ghidra.pyghidra.PyGhidraScriptProvider.getScriptInstance`). Confirms
    both the GP-5415 default-to-PyGhidra behavior and that PyGhidra needs
    its own launcher, not just any Ghidra process.
  - The *same* `.py` script run via `pyghidraRun -H <same analyzeHeadless
    arguments>` instead of `analyzeHeadless` directly — **works**,
    identical 8-line output. `pyghidraRun --help` shows a `-H`/`--headless`
    flag whose usage banner is byte-for-byte the `analyzeHeadless` usage
    text — same CLI, different launcher/JVM bootstrap (one that starts the
    CPython/JPype bridge first).
  - A `.py` script with an explicit `# @runtime Jython` header comment via
    plain `analyzeHeadless` — **works** (Jython extension happened to
    already be installed in this user's Ghidra settings directory from
    prior use), confirming the opt-in tag path.
  - Conclusion for the guide: **PyGhidra scripts must be launched through
    `pyghidraRun`** (GUI or `-H` headless), not plain `analyzeHeadless`/
    `ghidraRun` — this is the one practical gotcha worth calling out
    clearly, since the error message alone doesn't say what to do instead.
- PyGhidra mechanics: JPype-based bridge (`Ghidra/Features/PyGhidra/lib/
  PyGhidra.jar` + bundled `jpype1` wheels under `pypkg/dist/`), supports
  Python 3.9–3.14 per `GettingStarted.md`'s prerequisites section, and ships
  an example script (`ghidra_scripts/PyGhidraBasics.py`) demonstrating
  direct Java-object interop (`from java.util import LinkedList`,
  `jpype.JArray`, automatic getter-property access like
  `currentProgram.name` for `getName()`).
- **Standalone use (not just inside Ghidra)**: `pip install pyghidra` (or
  offline from `<GhidraInstallDir>/Ghidra/Features/PyGhidra/pypkg/dist`)
  installs the same library for use from a plain Python environment, no
  `analyzeHeadless`/GUI involved — `pyghidra.start()`,
  `pyghidra.open_project()`, `pyghidra.program_context()`/
  `program_loader()` (the current, non-deprecated API; `open_program()` is
  now documented as deprecated in favor of these, per its own docstring in
  `pypkg/src/pyghidra/core.py`). This path was **not** executed live in
  this session (would need a `pip install` — offline wheels exist in the
  distribution but weren't installed to avoid an unrequested network/venv
  side effect); documented from the shipped `pypkg/README.md` only.
- Old `Window → Python` Jython interpreter (from the training-class deck,
  "Python support in Ghidra" slides, Jython 2.7.1) is legacy behavior tied
  to the now-optional Jython extension — PyGhidra's equivalent is its own
  interactive CPython REPL launched the same way (`pyghidraRun`, no `-H`).
  Not independently re-verified live (didn't launch the interactive REPL,
  only headless script runs) — flagged as docs-only in the guide.

## 3. Headless Analyzer

- Full CLI synopsis, `-import`/`-process` mode exclusivity, `-preScript`/
  `-postScript`/`-scriptPath`/`-propertiesPath`/`-scriptlog`/`-log`/
  `-overwrite`/`-mirror`/`-recursive`/`-readOnly`/`-deleteProject`/
  `-noanalysis`/`-processor`/`-cspec`/`-analysisTimeoutPerFile`/
  `-max-cpu`/`-loader` flags — all from `support/analyzeHeadlessREADME.md`
  directly (the file is the authoritative reference, not paraphrased from
  a second-hand source).
- Default script search path when `-scriptPath` is omitted:
  `$USER_HOME/ghidra_scripts` plus every `ghidra_scripts` subdirectory that
  exists anywhere in the distribution — same file. **Verified live**: an
  actual run's startup log printed this exact list (11 directories on this
  install, including two from installed extensions —
  `.../Extensions/ghidra-amiga/ghidra_scripts` and one other), confirming
  `-scriptPath` *adds* to this list rather than replacing it (see §1's
  collision finding — this is the mechanism behind it).
- `-scriptlog` vs. `-log`: script log only captures the built-in
  `print`/`println`/`printf`/`printerr` scripting calls; general
  analysis/import logging goes to `-log`'s target (`application.log` by
  default). Doc explicitly calls out that Python's native `print()` goes to
  stdout, not the script log — use `println` from a script for anything
  that must land in the script log file.
- Program disposition control (pre/post scripts can decide to abort further
  processing or delete the current file after processing) and the
  `askXxx()`-via-`.properties`-file mechanism for headless parameter
  passing — both documented in the same README's "Scripting" section, not
  independently re-verified live (used a script with no `askXxx()` calls
  for the live tests, to avoid needing a `.properties` file).

## Unresolved / not independently verified

- The standalone `pip install pyghidra` workflow (§2) — documented from the
  shipped README only, not run.
- The `askXxx()` + `.properties`-file headless parameter-passing mechanism
  (§3) — documented from the README only, not run against a real script
  that calls `askString`/`askInt`/etc.
- The PyGhidra interactive CPython REPL (`pyghidraRun` without `-H`) and
  the legacy Jython interpreter (`Window → Python`) — neither launched
  live; both documented from docs/training-deck text only.
- The "`Ghidra was not started with PyGhidra`" error (§2) was reproduced
  live for **headless** (`analyzeHeadless`) only — this environment has no
  display, so the GUI (`ghidraRun`) case wasn't separately launched.
  `01-script-manager-java-api`'s and `02-python-scripting-jython-pyghidra`'s
  exercises still have the student trigger it via the GUI, on the
  reasoning that the check
  (`ghidra.pyghidra.PyGhidraScriptProvider.getScriptInstance`, per the
  headless stack trace) tests a JVM-startup-time flag rather than anything
  headless-specific — high confidence, not independently confirmed in this
  session.
- Exact byte-for-byte GhidraDev version compatibility with Eclipse/PyDev
  for this specific 12.1.2 release wasn't checked beyond confirming the zip
  ships (`GhidraDev-5.0.1.zip`) — no Eclipse installation available in this
  environment to test the actual plugin install.

## Aside, not part of this module's content but worth flagging for Phase 12

This machine's Ghidra user settings directory
(`~/Library/ghidra/ghidra_12.1.2_PUBLIC/Extensions/`) already has a
`GhidraMCP` extension installed (`extension.properties`: version `12.1.2`,
i.e. already pinned to this exact Ghidra release, author "Ben Ethington" —
the LaurieWired GhidraMCP project). Not used or evaluated in this phase
(out of scope — 05-automation-scripting is plain scripting, not MCP), but
Phase 12's MCP research/recommendation step should know a real,
version-matched install already exists locally and could be used for
firsthand evaluation instead of research-only assessment.
