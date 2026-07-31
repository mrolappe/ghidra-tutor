# Limits and verification duty

Guide 1's central lesson, restated as a rule: **never accept a Ghidra change
an AI agent proposes without reviewing it against the actual decompiled
code.** This guide makes that concrete — one structural mitigation
(disabling the `Scripting` tool group) and one habit (reviewing before you
approve a write), both demonstrated against ReVa specifically.

## Why this isn't optional caution

Guide 1 already showed the mechanism: a string sitting in the binary you're
analyzing — a section name, a debug string, anything `get-strings` or
`decompile-function` surfaces — becomes ordinary text in the agent's context
the moment a tool call returns it. Nothing marks it as "data from an
untrusted source" rather than "instruction from the user." This is
structural to how every current Ghidra MCP server works (guide 1's
repo-wide search for "prompt injection" across all five evaluated projects:
zero hits), not a ReVa-specific gap.

ReVa's own server code is unusually explicit about this asymmetry. Reading
`McpServerManager.approvePublicBinding()` directly (not paraphrasing the
README): the moment the server would bind somewhere other than loopback
without an API key, it builds this exact warning —

> ReVa is about to bind to `<host>` (a non-localhost interface) with API key
> authentication DISABLED. Anyone who can reach this port can read and
> modify your Ghidra programs [and RUN ARBITRARY PYTHON CODE on this host
> (the run-script tool is enabled), if the Scripting group is on]. To secure
> it: bind to 127.0.0.1, or enable API key authentication. [Disabling the
> Scripting tool group removes the remote code-execution risk, but the
> server remains reachable on this interface.]

In headless mode this isn't a warning you can dismiss — the server refuses
to start and logs "Refusing to start." In GUI mode it's a modal consent
dialog with an "allow once" / "allow always" choice, not silent. That's
guide 1's point #1 in code: the *network* boundary is enforced structurally.
What it does **not** do — what no server in the field does — is anything
about boundary ②, tool-result text reaching the LLM's context unmarked. That
boundary is entirely on you.

## Mitigation 1: disable Scripting before pointing ReVa at an untrusted binary

ReVa's tool providers are grouped, and the grouping is meaningful — reading
`McpServerManager.createProvidersForGroup()` directly:

| Group | Tools |
|---|---|
| Core Analysis | symbols, strings, functions, decompiler, memory, xrefs, constant search, import/export, project |
| Data & Types | data, data types, structures |
| Advanced Analysis | call graph, data flow, vtables |
| Diff | binary diff |
| Annotations | comments, bookmarks |
| **Scripting** | run arbitrary Python against the open program |

Every group except Scripting is read-or-annotate — even a fully successful
prompt-injection attack through, say, `Core Analysis`'s rename tools costs
you a wrong function name you'll catch on review. **Scripting is
categorically different**: it's arbitrary code execution on your machine,
which is a different threat model than "the agent renamed a function badly."

Before pointing ReVa at a binary you didn't build yourself or otherwise
don't already trust: **Ghidra → Edit → Tool Options → "ReVa Tool Groups" →
uncheck "Scripting"** (GUI), or `reva.tool.groups.scripting=false` in the
config file (headless). This doesn't fix boundary ② — a malicious string can
still steer a rename or a misleading comment — but it removes the one
category of consequence that isn't recoverable by reviewing a diff
afterward.

## Mitigation 2: review before accepting, every time

Everything else the agent proposes — a rename, a retype, a comment, a
structure definition — is a **hypothesis**, not a fact, exactly like
guide 1 frames it. The check is the same one `01-core-workflows/02-decompiler-tuning.md`
already asks you to do manually when Ghidra's own heuristics guess a
signature:

1. Read the actual decompiled/disassembled code the proposed change is
   based on — not just the agent's prose summary of it.
2. Ask: does the proposed name/type/comment match what the code *does*, or
   only what looks plausible given the function's neighbors and naming
   conventions? (This is where a model trained on modern C/C++ can mislead
   itself on retro platforms — it may pattern-match a 6502 KERNAL-call site
   to a name that "sounds right" for a jump table without having actually
   looked up `$FFD2` in the table.)
3. Only then approve the write. If your AI client prompts per-tool-call
   (Claude Code's default), don't blanket-`/permissions`-allow write tools
   for a session touching an unfamiliar binary — leave them prompting, so
   step 3 is a deliberate action, not a formality you've trained yourself to
   click through.

The exercise for this guide walks exactly this: the agent proposes a
rename/retype against one of this course's own sample binaries, and you
verify it against the real decompiled output before committing it —
matching the pattern you already know from the manual annotation exercises
in `00-quickstart` and `01-core-workflows`, just with the proposal coming
from a model instead of from you reading cold.

---

**Self-check:** you've disabled the `Scripting` tool group and you're only
using `Core Analysis` and `Annotations`. Does that mean you can safely
blanket-approve every tool call for the session? → No. Disabling Scripting
removes the remote-code-execution consequence specifically, but a
prompt-injected string can still steer `Core Analysis`'s rename/comment
tools or `Annotations`' bookmark/comment tools into writing something
false or misleading into your program database — wrong, not dangerous to
your machine, but still wrong, and still something only you reviewing the
actual decompiled code will catch. The tool-group toggle narrows *what kind*
of damage is possible; it doesn't remove the need to look at what's being
written before it lands.
