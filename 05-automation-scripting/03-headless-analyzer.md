# The Headless Analyzer

Everything so far in this module still needed the GUI open. The Headless
Analyzer is the command-line entry point for the same import → analyze →
script pipeline, for batch work: a whole directory of binaries, a CI job, a
nightly re-analysis run.

## Basic shape

```sh
<GhidraInstallDir>/support/analyzeHeadless \
    <project_location> <project_name>[/<folder_path>] \
    -import <directory-or-file> [-recursive] \
    -preScript <Script.ext> [args...] \
    -postScript <Script.ext> [args...] \
    -scriptPath "<path1>;<path2>..." \
    -deleteProject
```

`<project_location>`/`<project_name>` behave like any Ghidra project — an
existing one is reused (and grows), a new one is created if it doesn't
exist yet. Two mutually exclusive modes decide what gets processed:

- **`-import`** — bring in new file(s)/directories (optionally
  `-recursive`), then analyze and script them.
- **`-process`** — re-run scripts/analysis over file(s) *already in* an
  existing project, without importing anything new. Only one `-process`
  per invocation (unlike `-import`, which can repeat).

## Pre-scripts vs. post-scripts

Both are optional, both can be repeated (each use of the flag adds one more
script to the pipeline), and each is just a normal `GhidraScript` — nothing
headless-specific about the script code itself:

- **`-preScript`** runs *before* auto-analysis — the place to force
  analysis on/off for this file, or set analyzer options a script wants
  honored.
- **`-postScript`** runs *after* — the place for anything that reads
  analysis results: renaming, retyping, exporting a report, deciding
  whether this file's disposition (keep/delete, commit/skip) should
  change.

Script names are given **without a path** — `-postScript MyScript.java`,
not a full file path. Resolution searches, in combination:

- every directory named by `-scriptPath` (if given),
- `$USER_HOME/ghidra_scripts`,
- **every** `ghidra_scripts` directory anywhere in the Ghidra distribution
  (there are a dozen-plus — Base, Decompiler, individual processor
  modules, installed extensions, ...).

That last point matters more than it looks: `-scriptPath` *adds* a search
location, it doesn't replace the built-in ones. **Give your scripts unique
filenames.** A script named `ListFunctions.java` in your own `-scriptPath`
directory can be silently shadowed by a same-named script already shipping
inside a Ghidra feature module — Ghidra runs whichever one it finds first,
with no warning that a name collision happened. (Verified directly:
renaming a test script from `ListFunctions.java` to something project-
specific was the actual fix, not a hypothetical.)

## Logging: two separate files

- **`-log`** — the general import/analysis log (`application.log` by
  default if not set).
- **`-scriptlog`** — output from `println`/`print`/`printf`/`printerr`
  calls made *inside* pre/post scripts specifically (`script.log` by
  default).

One easy-to-miss detail: in a Python script, plain `print()` goes to
**stdout**, not the script log — use `println()` from the Flat API if the
output needs to land in `-scriptlog`'s file.

## Running a PyGhidra script headlessly

`analyzeHeadless` alone can't run a PyGhidra-default `.py` script — same
restriction as the GUI (guide 2): plain `analyzeHeadless -postScript
foo.py` fails with `Ghidra was not started with PyGhidra. Python is not
available`. The fix is to swap the launcher, not the arguments —
`pyghidraRun` accepts an identical CLI under `-H`:

```sh
<GhidraInstallDir>/support/pyghidraRun -H \
    <project_location> <project_name> \
    -import <file> \
    -postScript MyScript.py \
    -scriptPath <dir> \
    -deleteProject
```

Same project/import/script flags, same output shape — just routed through
the launcher that boots the CPython bridge first. A `.py` script explicitly
tagged `# @runtime Jython` runs fine under plain `analyzeHeadless`, no
`pyghidraRun` needed — only the PyGhidra runtime has this requirement.

## Other flags worth knowing up front

| Flag | Effect |
|---|---|
| `-readOnly` | analyze/script without saving changes back |
| `-overwrite` | replace a conflicting existing project file (ignored with `-readOnly`) |
| `-noanalysis` | import without running auto-analysis at all |
| `-deleteProject` | discard the whole project when the run finishes — handy for one-shot CI use |
| `-analysisTimeoutPerFile <seconds>` | cap analysis time per file, so one pathological binary can't hang a batch run |
| `-max-cpu <n>` | cap analyzer thread/core usage |
| `-processor <languageID>` / `-cspec <compilerSpecID>` | override auto-detected language/compiler spec |

## Program disposition and parameter passing (pointers, not depth)

Two Headless-specific mechanics exist beyond what's shown here — both
documented in `support/analyzeHeadlessREADME.md`'s "Scripting" section in
more depth than this guide covers:

- A pre/post script can programmatically control **disposition** — abort
  further processing of the current file, or mark it for deletion after
  the run — useful for "skip files that don't match X" batch logic.
- `askXxx()` calls (`askString`, `askInt`, ...) that would normally pop a
  GUI dialog instead read from a `.properties` file in headless mode (see
  `-propertiesPath`) — lets the same script source run both interactively
  and headlessly.

---

**Self-check:** a headless run's log shows your `-postScript` executed
successfully, but the output isn't what your script prints — it looks like
a different, unrelated script ran instead. Given only what's in this
guide, what's the most likely cause, and how would you confirm it from the
log? → A script-name collision with a same-named script elsewhere in the
default search paths (distribution or extension `ghidra_scripts`
directories) — the log's `SCRIPT: <resolved path>` line shows exactly which
file actually ran.
