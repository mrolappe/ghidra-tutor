# Solution: The Headless Analyzer

## Part A

```java
//@category GhidraLernen.Exercises
public class CountFunctionsScript extends ghidra.app.script.GhidraScript {
    public void run() throws Exception {
        int n = currentProgram.getFunctionManager().getFunctionCount();
        println(currentProgram.getName() + ": " + n + " functions");
    }
}
```

Verified output, batch-importing the `batch/` directory in one invocation
(this project's reference build; exact counts will vary slightly by
platform/compiler but the two-files-one-run shape is what matters):

```
CountFunctionsScript.java> quickstart-sample.bin: 7 functions
CountFunctionsScript.java> core-workflows-sample.bin: 10 functions
```

Two full import→analyze→script cycles in the log, one per file — confirms
`-import <directory>` processes every file it finds, running the same
post-script pipeline against each independently.

## Part B — the collision, reproduced

Renaming to `ListFunctions.java` and rerunning: the log's `SCRIPT:` line
now points **inside the Ghidra installation**, not at your script folder —
e.g. `SCRIPT: <GhidraInstallDir>/Ghidra/Features/FunctionID/ghidra_scripts/
ListFunctions.java`. That's Ghidra's own built-in Function-ID-database
export script, which happens to share your chosen filename.

The output makes this obvious fast, not subtle: the built-in script isn't
a function-lister at all — it prompts (`askFile`) for a FID database and
an output file to dump matched-function info to. Run headlessly with no
matching `.properties` file, it fails outright:

```
ERROR REPORT SCRIPT ERROR: java.lang.IllegalArgumentException: Error
processing variable 'Output file Choose output file:' in headless mode --
it was not found in script arguments or a .properties file.
```

Renaming the file back to something project-specific
(`CountFunctionsScript.java`, or any name not already used anywhere in the
distribution) fixes it immediately — the `SCRIPT:` line goes back to
pointing at your own file, and the output matches Part A again.

## Check-yourself answer

No — pointing `-scriptPath` *only* at your own folder would **not** have
prevented this. Per guide 3, `-scriptPath` **adds** a search location; it
never replaces the built-in ones (every distribution `ghidra_scripts`
directory, plus `$USER_HOME/ghidra_scripts`, are always searched
regardless of what `-scriptPath` says). The only real fix is avoiding
filename collisions in the first place — pick names specific enough that
they won't already exist somewhere in a Ghidra install or its extensions
(a project-specific prefix, as used throughout this module's exercises, is
enough).
