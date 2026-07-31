# First Project, Import, Auto-Analysis

## Create a project

From the Ghidra Project Window: `File → New Project...`. In the wizard, keep
**Non-Shared Project** selected — that's a project for you alone, with no
Ghidra Server involved. ("Shared Project" is for team setups; out of scope
here.)

## Import a binary

`File → Import File...` (shortcut **I**), from either the Project Window or
an open CodeBrowser. Pick your file, and Ghidra opens the **Importer
Dialog** with its best guess at format/language/compiler — check these look
right, then OK. (Multi-program archives instead open a **Batch Importer
Dialog**.) Drag-and-drop onto the project tree works too.

If you imported from the Project Window, double-click the new program in the
tree to open it in CodeBrowser.

## Auto-Analysis

The first time a program opens in CodeBrowser, Ghidra offers to analyze it —
you'll be asked before anything runs. Accepting opens the **Auto Analysis
Options** dialog: every analyzer, listed with a checkbox, defaults tuned for
most binaries. Two worth knowing about as a first-timer:

- **ASCII Strings** — finds likely ASCII strings and marks them as String
  data. Low priority, runs late.
- **Decompiler Parameter ID** — runs the decompiler per function and imports
  back what it recovers: parameters, locals, return value, calling
  convention, switch tables.

Leaving defaults on is the right call your first few times through.

> The exact button/title wording of the "analyze now?" prompt isn't
> documented outside the shipped app — check what your installed version
> actually shows.

### What "Analyze" actually does

Auto-Analysis is a pipeline of analyzer plugins that react to changes in the
program, not one monolithic pass. Roughly: disassembly starts at entry
points and follows control flow → a reference analyzer creates functions at
call targets → a stack analyzer builds each new function's stack frame from
its stack references → an operand analyzer flags scalar operands that look
like addresses → a data-reference analyzer resolves those into
strings/pointers/code, which can trigger further disassembly. Analyzers run
at different priorities, so one change can cascade through several of them.

You can re-run it anytime via `Analysis → Auto Analyze '<program>'...`.

---

**Self-check:** you import a file and CodeBrowser shows raw bytes with no
functions or strings — what did you probably skip? → Declining (or not being
asked) to run Auto-Analysis; trigger it via `Analysis → Auto Analyze`.
