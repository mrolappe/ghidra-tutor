# Exercise: Data Types & Structures

Covers [`01-data-types-structures.md`](../../01-data-types-structures.md).
Uses the shared [`sample/`](../sample/) program — the same import used by
this whole module's exercises 01–03.

## Build & import

```sh
cd sample
./build.sh
```

Import `sample/sample.bin` into a project and auto-analyze it, same routine
as 00-quickstart. Keep this project around for exercises 02 and 03.

## Tasks

1. In the Decompiler, open the function that Ghidra currently shows as
   something like `FUN_<addr>(int *param_1,int param_2)` and whose body is a
   loop that adds `param_1[i * 6 + 1]` into an accumulator (this is
   `total_quantity`). Don't rename it yet — first read the raw pointer
   arithmetic: what does the `* 6 + 1` tell you about the size and layout of
   whatever `param_1` points to?
2. In the Data Type Manager, create a new **Structure** (right-click a
   category → **New → Structure**) with three fields, in order: `id` (`int`,
   offset 0), `quantity` (`int`, offset 4), `name` (`char[16]`, offset 8).
   Confirm the editor reports a total size of **24** bytes (`0x18`) — the
   same stride you just read out of the decompiled loop.
3. Find the global array this function iterates over (`inventory`, visible
   as data in the Listing/Symbol Tree once you follow a reference into it
   from the loop). Select it and apply your new structure as an array of 4
   elements (right-click → Data → your structure, or clear+retype the
   selection as `Item[4]`).
4. Back in the Decompiler, confirm `total_quantity`'s loop now reads as
   `items[i].quantity` instead of raw offset math, and that the other
   function writing into this array (`init_item`) now takes an `Item *`
   parameter and shows `it->id`, `it->quantity` style field writes instead
   of raw stores.
5. Retype `init_item`'s first parameter explicitly to a pointer to your
   structure if it didn't pick this up automatically (Decompiler → click the
   parameter → **Ctrl+L**).

**Check yourself:** you only applied the structure in *one* place (the
`inventory` array), yet both `total_quantity` and `init_item`'s Decompiler
output changed — why does a single data type edit ripple across multiple
functions like that?
