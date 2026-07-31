# Exercise: Review before you accept

Covers [`04-verification-and-limits.md`](../../04-verification-and-limits.md).
Part A/B use **real Ghidra decompiler output**, captured headless in this
project's own environment (`pyghidraRun -H` against
`01-core-workflows/exercises/sample/sample.bin` with a decompile-and-print
post-script) — not hand-transcribed, unlike the illustrative
`click-to-annotate-demo.html` from `01-core-workflows`. You're reviewing two
*invented* AI proposals against *real* output, which is exactly the
situation this guide is about.

## Part A — the struct-stride function

Real captured output for one function (stripped binary, default naming):

```c
int FUN_1000006c0(long param_1,int param_2)

{
  undefined4 local_14;
  undefined4 local_10;

  local_10 = 0;
  for (local_14 = 0; local_14 < param_2; local_14 = local_14 + 1) {
    local_10 = local_10 + *(int *)(param_1 + (long)local_14 * 0x18 + 4);
  }
  return local_10;
}
```

An AI agent, asked to explain and rename this function, proposes:

> Rename to `sum_prices`. Retype `param_1` as `int *`. Comment: "Iterates
> over an array of prices and returns their total."

1. Does the proposed retype (`int *`) match what the code actually does
   with `param_1`? Look specifically at the stride the loop advances by
   (`* 0x18`, i.e. 24 bytes) versus what `int *` arithmetic would imply.
2. What does the `+ 4` inside the cast tell you that a plain `int *` type
   completely discards? (You've seen this pattern before —
   `01-core-workflows/01-data-types-structures.md` is the guide to check.)
3. Write the retype you'd actually apply instead, and name one concrete
   Ghidra action (not just "define a struct") you'd take to make future
   decompiles of this function self-documenting.

## Part B — the hallucinated behavior

Second real captured function from the same run:

```c
void FUN_100000730(int param_1,undefined4 param_2,undefined4 param_3)

{
  (*(code *)(&PTR_FUN_100008000)[param_1])(param_2,param_3);
  return;
}
```

The same agent proposes:

> Rename to `apply_validated_operation`. Comment: "Validates that `param_1`
> is a legal operation index before dispatching through the function
> pointer table, preventing out-of-bounds calls."

4. Find the bounds check the comment describes, in the code above. Is it
   there?
5. Why is this kind of proposal more dangerous to accept unreviewed than
   Part A's — what's the difference between "wrong type" and "describes a
   safety check that doesn't exist," in terms of what happens if you act on
   each without checking?

## Part C — disable Scripting before pointing ReVa at something you don't trust

6. Using `02-setup.md`'s config reference, write the exact GUI path (menu →
   submenu → checkbox) to disable ReVa's `Scripting` tool group from a
   running Ghidra session.
7. Write the equivalent one-line headless config-file setting.
8. Per `04-verification-and-limits.md`'s tool-to-group table: after
   disabling `Scripting`, is the rename proposed in Part A still something
   the agent could execute through ReVa if you approved it? Why — which
   tool group does a rename actually live in?

**Check yourself:** Part A's proposed retype is wrong, and Part B's
proposed comment describes something that isn't in the code at all — both
are "AI suggestions you shouldn't accept unreviewed." Which failure mode do
you think is more common in practice, a wrong technical claim you can check
mechanically (like a type not matching a stride) versus a plausible-sounding
behavioral claim that requires you to actually trace the code to disprove —
and what does that imply about which parts of an AI's explanation deserve
the most scrutiny?
