# Progress Log

Plan reference: see [PLAN.md](PLAN.md) for the full phase table, module
contents, model recommendations, and the visual/interactive material list.
This file only tracks what's done, what's next, and facts later phases need.

## Completed

- Phase 0 — Repo setup: git initialized, public GitHub repo `ghidra-tutor`
  created, module folder skeleton created, root `README.md`, `PLAN.md`,
  `CLAUDE.md` and this `PROGRESS.md` added.

## Carried-forward notes

- Git remote uses **HTTPS** with the `gh` credential helper (`gh auth
  setup-git`), not SSH — the SSH push failed because no key is set up in
  `~/.ssh/config`/agent. Plain `git push`/`git pull` work as-is; don't switch
  the remote back to `git@github.com:...`.
- Default branch is `main`. GitHub repo: https://github.com/mrolappe/ghidra-tutor (public, owner `mrolappe`).
- The 7 module folders + `exercises/.gitkeep` placeholders already exist —
  later phases only add files into them, no need to `mkdir` again.

## Next

- Phase 1 — 00-quickstart: Guides
  - Content: installation/setup, first project + import + auto-analysis,
    UI tour (Listing, Decompiler, Symbol Tree, Data Type Manager, Function
    Graph), basic annotations (rename/retype/comment), cross-references/
    bookmarks, search, shortcut cheatsheet (markdown version; interactive
    HTML cheatsheet comes in Phase 2 alongside exercises).
  - Model: Sonnet 5.
  - No open questions/assumptions to flag yet.
