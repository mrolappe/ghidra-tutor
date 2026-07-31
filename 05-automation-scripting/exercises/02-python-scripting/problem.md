# Exercise: Python scripting (PyGhidra)

Covers
[`02-python-scripting-jython-pyghidra.md`](../../02-python-scripting-jython-pyghidra.md).
Same shared program as exercise 01
(`01-core-workflows/exercises/sample/sample.bin`) — reuse the project you
already have open, or re-import it.

## Part A — predict, then verify the launcher gotcha

1. With a normal `ghidraRun`-launched Ghidra (whatever you've been using
   all along), open the Script Manager and create a new script, language
   **Python**, named `ExerciseListFunctionsPy.py`. Give it this body (no
   `@runtime` tag — leave it untagged):

   ```python
   # @category GhidraLernen.Exercises
   functions = currentProgram.getFunctionManager().getFunctions(True)
   filter_str = askString("Filter", "Only show functions containing:", "")
   count = 0
   for f in functions:
       if not filter_str or filter_str in f.getName():
           print(f"{f.getEntryPoint()} {f.getName()}")
           count += 1
   println(f"Total matched: {count}")
   ```

2. Before running it — **predict**: given guide 2's launcher section, do
   you expect this to run, and if not, what error do you expect? Then
   click Run and check.
3. Close Ghidra. Relaunch it via `<GhidraInstallDir>/support/pyghidraRun`
   instead of the normal shortcut/`ghidraRun`. Re-open your project and run
   the same script again. Confirm it now works.

## Part B — write it, run it headlessly too

4. Still in the PyGhidra-launched session, adjust the script to also print
   `currentProgram.name` (property-style access, not `.getName()`) as its
   first line of output, to see PyGhidra's Java-getter-as-property
   convenience for yourself.
5. Now try it from the command line instead of the GUI, using the CLI form
   from guide 3:

   ```sh
   <GhidraInstallDir>/support/pyghidraRun -H \
       /tmp/pyghidra-exercise MyProj \
       -import <path-to>/01-core-workflows/exercises/sample/sample.bin \
       -postScript ExerciseListFunctionsPy.py \
       -scriptPath <folder containing your script> \
       -propertiesPath <same folder> \
       -deleteProject
   ```

   You'll need an `ExerciseListFunctionsPy.properties` file next to the
   script for the headless `askString` call — format:
   `Filter Only show functions containing: = printf`.

**Check yourself:** in Part A step 2, what specifically in the script (or
lack thereof) is what triggers PyGhidra as the runtime, rather than
Jython — and would adding `# @runtime Jython` above `# @category` have
changed whether step 2 failed?
