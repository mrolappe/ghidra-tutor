# Solution: Data Types & Structures

1. `param_1[i * 6 + 1]` means each element is **6 ints wide** (24 bytes), and
   the field being read sits at int-index 1 (byte offset 4) within each
   element — a strong signal that `param_1` points at an array of some
   24-byte structure, and this particular field is its second 4-byte member.
2. `Item { int id; int quantity; char name[16]; }` — `id` at 0, `quantity`
   at 4, `name` at 8, total 24 bytes. No padding is needed here since 8 + 16
   = 24 is already 4-byte aligned, so the size matches the stride from step
   1 exactly.
3–4. Once `Item[4]` is applied to `inventory`, the loop in `total_quantity`
   should read as `total = total + items[i].quantity;` and `init_item`'s
   decompiled body should show `it->id = id; it->quantity = qty;` plus a
   `strncpy`/write into `it->name` — matching offsets 0, 4, and 8 from your
   structure definition.
5. If `init_item`'s parameter didn't auto-retype, `Ctrl+L` on it in the
   Decompiler opens the Retype Parameter dialog — pick `Item *`
   (or the pointer Ghidra auto-created when you applied the struct,
   `Item *`, from the Data Type Manager tree).

**Check yourself — answer:** a data type in Ghidra is a program-wide
definition, applied *by reference* wherever it's used — the Decompiler
doesn't store its own copy of "what this memory looks like" per function.
Every function that reads/writes through a location typed as `Item`/`Item *`
re-renders using the current definition of that one shared type, so editing
or applying the structure once updates every caller's view simultaneously.
