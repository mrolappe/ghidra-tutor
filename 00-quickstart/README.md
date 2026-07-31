# 00 — Quickstart

Get productive in Ghidra quickly, for everyday use. Read these guides in
order the first time; afterwards, use them as reference.

```mermaid
flowchart LR
    A[Import] --> B[Analyze]
    B --> C[Browse]
    C --> D[Annotate]
    D --> E[Export]
    D -.-> C
```

1. [Installation & setup](01-installation-setup.md)
2. [First project, import, auto-analysis](02-first-project-import-analysis.md)
3. [UI tour](03-ui-tour.md)
4. [Basic annotations](04-basic-annotations.md)
5. [Cross-references, bookmarks, search](05-xrefs-bookmarks-search.md)
6. [Shortcut cheatsheet](06-shortcut-cheatsheet.md)

Facts in these guides are checked against the Ghidra 12.1.2 documentation and
source. Ghidra's UI has stayed stable across versions in the areas covered
here, but if something on your screen doesn't match, trust your installed
version — and check `Help → Contents` for the copy that ships with it.
