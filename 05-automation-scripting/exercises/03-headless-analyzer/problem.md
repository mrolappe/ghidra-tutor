# Exercise: The Headless Analyzer

Covers [`03-headless-analyzer.md`](../../03-headless-analyzer.md). Uses
**two** already-built sample binaries from earlier modules — no new sample
needed, this module deliberately reuses what's already verified:

```sh
cd ../../../00-quickstart/exercises/02-first-import-analysis/sample && ./build.sh && cd -
cd ../../../01-core-workflows/exercises/sample && ./build.sh && cd -
mkdir -p batch
cp ../../../00-quickstart/exercises/02-first-import-analysis/sample/sample.bin batch/quickstart-sample.bin
cp ../../../01-core-workflows/exercises/sample/sample.bin batch/core-workflows-sample.bin
```

(`batch/` is gitignored the same way `*.bin` already is everywhere else in
this repo — nothing to commit here, it's scratch space for the exercise.)

## Part A — batch-count functions across both binaries

1. Write `CountFunctionsScript.java`: a `GhidraScript` that prints
   `currentProgram.getName()` and `currentProgram.getFunctionManager()
   .getFunctionCount()`.
2. Run it as a post-script over the whole `batch/` directory in one
   `analyzeHeadless` invocation (not two separate ones):

   ```sh
   analyzeHeadless /tmp/batch-project BatchProj \
       -import batch \
       -postScript CountFunctionsScript.java \
       -scriptPath <folder containing your script> \
       -deleteProject
   ```
3. Confirm the log shows two separate `IMPORTING:`/analysis/script cycles,
   one per file, each with its own function count.

## Part B — reproduce the name-collision gotcha on purpose

4. Copy your script to a **new file** named `ListFunctions.java` (same
   `run()` body, class renamed to match) and run it the same way as step 2,
   `-postScript ListFunctions.java`.
5. Look at the log's `SCRIPT:` line for each file — does it point at your
   script, or somewhere inside the Ghidra installation directory? What
   does the printed output look like compared to Part A's?
6. Explain what happened, referencing guide 3's script-search-path
   section. Fix it (you already know how — same fix guide 3 names) and
   confirm the log's `SCRIPT:` line now points where you expect.

**Check yourself:** would `-scriptPath` pointing *only* at your own script
folder (nothing else) have prevented step 4's collision? Why or why not,
given what guide 3 says about how `-scriptPath` combines with the default
search locations.
