# Python scripting: Jython (legacy) vs. PyGhidra (the default)

Everything in guide 1 — `GhidraScript`, the Flat API, script metadata, the
Script Manager — applies to a Python script exactly as written. What
changes is *which* Python runs it, and that's had a real shake-up since
older Ghidra material (including tutorials that still say "Ghidrathon is
the modern Python 3 option") was written.

## Two Python runtimes, one `.py` extension

Ghidra can run a `.py` script two different ways, distinguished by a
`# @runtime` metadata comment:

- **PyGhidra** — a native **CPython 3** interpreter, bridged to Ghidra's
  Java API via [JPype](https://jpype.readthedocs.io/en/latest). This is the
  **default** for any `.py` script with no `@runtime` tag.
- **Jython** — a **Java-implemented** Python 2.7 interpreter, running
  inside the same JVM as Ghidra (no bridge needed, but no Python 3 syntax
  or C-extension packages either). Opt in explicitly with
  `# @runtime Jython` at the top of the script.

```python
# @runtime Jython
# a Python 2-syntax script that explicitly asks for the legacy interpreter
```

If both this line and the file's actual syntax disagree (Python 3 code
with no `@runtime` tag defaulting to PyGhidra is fine; Python 3 code
force-tagged `@runtime Jython` will fail to parse), you'll get a normal
script-load error naming the mismatch.

## Why this is a change from what older material says

Two things moved since Ghidra's Python story was "Jython, built in; a
community project called Ghidrathon if you want Python 3":

1. **Jython stopped being built in.** It's now an optional Extension
   (`File → Install Extensions` → check Jython → restart). If you never
   install it, `@runtime Jython` scripts simply won't run — the interpreter
   isn't there.
2. **PyGhidra absorbed the Python-3-bridge role and shipped natively.**
   PyGhidra began life as "Pyhidra", built by the DoD Cyber Crime Center as
   an external CPython bridge — conceptually the same slot Ghidrathon
   filled. Ghidra integrated it directly (renamed PyGhidra) rather than
   continuing to point users at a separate community extension, and made
   it the **default** interpreter for untagged `.py` scripts.

Net effect: if you write a plain `.py` script today with no `@runtime`
comment, you're already on the modern native-CPython-3 path without having
installed anything extra. Jython is what now requires an extra step.

## The one gotcha: PyGhidra needs its own launcher

A PyGhidra script won't run from a Ghidra session that wasn't started
through PyGhidra's own launcher — confirmed for `analyzeHeadless` (headless
batch work, guide 3), and the same check applies regardless of headless vs.
GUI, since it's a JVM-startup-time flag ("was the CPython bridge
initialized before Ghidra came up"), not something that varies per script
run. Try it and you'll get exactly this:

```
Ghidra was not started with PyGhidra. Python is not available
```

PyGhidra needs the CPython/JPype bridge initialized *before* Ghidra starts,
which means launching through its own entry point:

```sh
<GhidraInstallDir>/support/pyghidraRun          # GUI, PyGhidra-enabled
<GhidraInstallDir>/support/pyghidraRun -H ...   # headless — see guide 3
```

The first run offers to create a Python virtual environment and install
the `pyghidra` package into it (wheels ship offline in the distribution
under `Ghidra/Features/PyGhidra/pypkg/dist/`, so this works without network
access); later runs reuse that venv automatically.

Launched this way, `pyghidraRun` also opens an interactive CPython REPL
inside the Ghidra GUI — the PyGhidra equivalent of the old `Window →
Python` Jython interpreter — for one-off exploration against
`currentProgram` without writing a script file at all.

## Writing PyGhidra scripts: it's still just Python

The Flat API fields and methods from guide 1 (`currentProgram`,
`askString()`, `println()`, ...) are all there, called exactly as in Java.
Two things feel different because you're in real Python:

```python
# @runtime PyGhidra   (optional — this is already the default)

# import a Java class like it's a normal Python module
from java.util import LinkedList
java_list = LinkedList([1, 2, 3])

# Java getters become Python properties automatically
print(currentProgram.name)          # calls currentProgram.getName()

# indexing, slicing, and list comprehensions work on Java collections
for block in currentProgram.memory.blocks:
    print(block.name)
```

For the rarer case of a Java API that needs a native array argument (e.g.
`Memory.getBytes(Address, byte[])`), use `jpype`'s array helper directly:

```python
import jpype
byte_array = jpype.JByte[10]          # a Java byte[10]
block.getBytes(block.start, byte_array)
```

## Standalone use: PyGhidra outside Ghidra entirely

PyGhidra is also a normal pip package, usable from any Python environment
with no Ghidra GUI or `analyzeHeadless` involved:

```sh
pip install pyghidra
```

```python
import pyghidra
pyghidra.start()                       # boots the JVM + Ghidra, headless

project = pyghidra.open_project("/path/to/projects", "MyProject", create=True)
# then: pyghidra.program_context() / program_loader() to get a program
#       and run analysis or a GhidraScript against it
```

This is worth knowing about even if you don't reach for it immediately: a
CI pipeline or a larger Python-based RE tool that wants to call into Ghidra
programmatically doesn't need to shell out to `analyzeHeadless` at all — it
can just `import pyghidra`. (`open_program()` — the older, simpler
one-call version of this — still exists but is documented as deprecated in
favor of `open_project()` + `program_context()`/`program_loader()`.)

---

**Self-check:** a teammate hands you a `.py` script with no `@runtime`
comment and says "run this with plain `ghidraRun`, it's a normal script."
It fails immediately. What's the most likely reason, and what do you
actually need to do differently? → No `@runtime` tag means PyGhidra by
default, and PyGhidra requires launching through `pyghidraRun` (or its
`-H` headless mode) — a plain `ghidraRun`/`analyzeHeadless` session has no
CPython bridge initialized to run it.
