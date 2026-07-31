# Solution: Decompiler Tuning

1. The indirect call is `apply_op`'s only interesting line — it reads an
   entry out of the `ops` function-pointer array and calls it, so the target
   is a runtime value, not a fixed address the Decompiler can resolve
   statically.
2. After the override, the call renders with `int` in/out instead of a
   generic/undefined prototype — but `op_add`/`op_sub` themselves are
   unaffected, since Override Signature is deliberately call-site-local (per
   the guide: for a *direct* call you'd fix the function itself instead;
   this is exactly the indirect case where you can't).
3. Whatever your platform's default C calling convention is called in your
   `.cspec` (e.g. `__cdecl`/`default` on Linux/macOS x86-64 — not the
   Windows-specific names from the guide's examples). The important part is
   confirming **Commit all return/parameter details** is checked, since a
   plain rename alone doesn't force a full commit.
4. `USER_DEFINED` — the highest-priority Source Type, set specifically by a
   full commit from the Function Editor dialog.
5. `Commit Params/Return` (**P**) also stamps `USER_DEFINED`, proving you can
   lock in a signature the Decompiler already inferred correctly without
   retyping anything by hand — useful whenever the analysis got it right and
   you just want to protect it from being reconsidered later.

**Check yourself — answer:** it survives. `USER_DEFINED` has priority 4, the
highest in the table; `ANALYSIS` (Auto Analysis, e.g. Decompiler Parameter
ID) is only priority 2. Later analysis passes are only allowed to overwrite
signatures at or below their own priority, so your hand-committed signature
stays locked in across re-analysis.
