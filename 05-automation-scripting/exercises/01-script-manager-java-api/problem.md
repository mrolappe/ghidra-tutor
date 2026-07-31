# Exercise: Script Manager & Java API

Covers [`01-script-manager-java-api.md`](../../01-script-manager-java-api.md).
Reuses `01-core-workflows/exercises/sample/sample.bin` — no new sample
needed, this module is platform-agnostic. If you haven't built it yet:

```sh
cd ../../../01-core-workflows/exercises/sample
./build.sh
```

Import and auto-analyze `sample.bin` in a project, same as always.

## Tasks

1. Open `Window → Script Manager`. Click **New** (or the "Create new
   script" button), choose Java, name it
   `ExerciseListFunctionsScript.java`, category `GhidraLernen.Exercises`.
2. Replace the generated `run()` body so the script:
   - asks the user for a filter substring (`askString`, Flat API),
   - iterates every function in `currentProgram` via its
     `FunctionManager`,
   - prints each function's entry point and name (`println`) if the
     filter is empty or contained in the name,
   - prints a final count of how many matched.

   (If you get stuck on exact method names, use the Script Manager's
   **Help** button — it opens `GhidraScript`'s Javadoc directly.)
3. Save and **Run** it with an empty filter. You should see every function
   in the program, including several still named `FUN_<address>` — this
   binary was stripped, so its local functions have no symbol names yet,
   only the two libc calls (`printf`, one of the `strncpy` variants) kept
   theirs.
4. Run it again with a filter of `printf`. Confirm only the matching
   function(s) print, and the count reflects that.
5. Add two metadata comment lines above the `import`/class declaration:
   `@keybinding ctrl shift 9` and confirm it shows up in the Script
   Manager's key-binding column (enable "In Tool" if needed for the
   binding to be live). Trigger the script with the keybinding instead of
   the Run button.

**Check yourself:** the guide draws a line between the Flat API and the
Program API. Which one did `askString`, `println`, and `getFunctionManager`
each come from — and what would change about your script's future-version
stability if you'd instead reached directly into `Function`/`Listing`
objects for everything instead of going through the manager/iterator
pattern shown here?
