# Solution: Script Manager & Java API

## The script

```java
//Lists functions in the current program, optionally filtered by a name substring.
//@category GhidraLernen.Exercises
//@keybinding ctrl shift 9
import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.Function;

public class ExerciseListFunctionsScript extends GhidraScript {
    public void run() throws Exception {
        String filter = askString("Filter", "Only show functions containing:", "");
        int count = 0;
        for (Function f : currentProgram.getFunctionManager().getFunctions(true)) {
            if (filter.isEmpty() || f.getName().contains(filter)) {
                println(f.getEntryPoint() + " " + f.getName());
                count++;
            }
        }
        println("Total matched: " + count);
    }
}
```

`getFunctions(true)` — the boolean is "forward" iteration order (by
address, ascending); `false` walks backward from the end of the program.

## Verified output (empty filter)

Run against `sample.bin` (this module's shared program — the `Item`
struct/function-pointer-array binary from `01-core-workflows`), on this
project's reference build:

```
100000548 entry
100000660 FUN_100000660
1000006c0 FUN_1000006c0
100000730 FUN_100000730
100000770 FUN_100000770
100000790 FUN_100000790
1000007b0 _printf
1000007bc ___strncpy_chk
Total matched: 8
```

(Exact addresses/count depend on your platform/compiler — the shape is
what matters: one `entry`, several stripped `FUN_<addr>` locals, and the
imported libc calls keeping their real names.)

Filtered to `printf`:

```
1000007b0 _printf
Total matched: 1
```

## Check-yourself answer

`askString`, `println`, and `getFunctionManager()` are all Flat API —
methods `GhidraScript` itself provides. `FunctionManager` and the
`Function` objects it hands back are Program API. The script above
already straddles both (as almost every real script does — the Flat API
alone can't do function iteration, `FunctionManager` is unavoidable here).
The distinction matters less for "does it work today" and more for "will
it still compile against a future Ghidra version" — `askString`/`println`
are guaranteed stable; `FunctionManager`'s exact shape is not, so a much
larger script leaning heavily on deep Program API traversal is more likely
to need updates across major Ghidra versions than one that stays close to
the Flat API surface.
