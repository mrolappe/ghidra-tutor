# Solution: Python scripting (PyGhidra)

## Part A

Step 2's expected (and actual, verified headlessly — see note below) error:

```
Ghidra was not started with PyGhidra. Python is not available
```

No `@runtime` tag defaults a `.py` script to PyGhidra (guide 2, GP-5415),
and PyGhidra requires its CPython/JPype bridge initialized at JVM startup —
a plain `ghidraRun` (or `analyzeHeadless`) session never does that, so the
script fails to load at all, before your code runs. Relaunching via
`pyghidraRun` fixes it because that's the launcher that does the bridge
initialization.

## Part B — the finished script

```python
# @category GhidraLernen.Exercises
print(f"Program: {currentProgram.name}")   # property-style, calls getName()

functions = currentProgram.getFunctionManager().getFunctions(True)
filter_str = askString("Filter", "Only show functions containing:", "")
count = 0
for f in functions:
    if not filter_str or filter_str in f.getName():
        print(f"{f.getEntryPoint()} {f.getName()}")
        count += 1
println(f"Total matched: {count}")
```

## Verified headless run

`ExerciseListFunctionsPy.properties`:
```ini
Filter Only show functions containing: = printf
```

```sh
pyghidraRun -H /tmp/pyghidra-exercise MyProj \
    -import sample.bin -postScript ExerciseListFunctionsPy.py \
    -scriptPath <dir> -propertiesPath <dir> -deleteProject
```

Output (this project's reference build):

```
1000007b0 _printf
Total matched: 1
```

Note the missing `Program: sample.bin` line in that captured output —
that's expected, not a bug: it comes from plain `print()`, which (per
guide 3) goes to **stdout** directly, not through the `println`-only
script log this exercise's log-grepping happened to filter on. Run it
yourself without filtering the output and you'll see both lines.

## Check-yourself answer

The trigger is the *absence* of `# @runtime Jython` — since GP-5415, no
`@runtime` tag at all means PyGhidra is assumed, not "no runtime
declared, ask the user." Yes, adding `# @runtime Jython` above `@category`
would have changed the outcome of step 2 — but not to "success": with
Jython tagged explicitly, the script would instead fail (or succeed,
depending on whether the Jython extension happens to be installed on your
machine) for a *different* reason entirely — Jython being an opt-in
Extension now, not built in (guide 2). Either way, the untagged version in
this exercise is specifically testing the PyGhidra-requires-its-own-
launcher gotcha, not the Jython-is-optional one.
