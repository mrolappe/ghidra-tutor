# Setting up ReVa

This guide installs [ReVa](https://github.com/cyberkaida/reverse-engineering-assistant),
guide 1's recommendation, against this course's Ghidra **12.1.2**. Every step
below was actually run in this environment (`~/ghidra_12.1.2_PUBLIC`, Java 21,
Gradle 8.8) — this isn't a transcription of the README, it's what happened
when the commands were executed. Where the environment couldn't confirm
something (no display, GUI-only step), that's called out explicitly instead
of asserted as fact.

## Build from source, not the release zip

Guide 1 already flagged why: ReVa's prebuilt release zip declares
`version=12.1`, and Ghidra's extension installer does an exact string
compare against your running Ghidra's version — a `12.1` vs `12.1.2`
mismatch pops an "Extension Version Mismatch" dialog with *Cancel* as the
default button.

Building from source instead:

```sh
git clone https://github.com/cyberkaida/reverse-engineering-assistant.git
cd reverse-engineering-assistant
export GHIDRA_INSTALL_DIR=/path/to/ghidra_12.1.2_PUBLIC
gradle install
```

**Confirmed hands-on**: this produces an installed extension whose
`extension.properties` reads `version=12.1.2` — an exact match, no mismatch
dialog. The version string isn't checked into the repo (it's a placeholder,
`version=@extversion@`); Ghidra's own `buildExtension.gradle` fills it in
from the `GHIDRA_INSTALL_DIR` you point the build at. Build the extension
against the same Ghidra install you'll run it in, and the version always
matches — this isn't specific to 12.1.2, it'll hold for whatever version you
build against.

`gradle install` unpacks the built extension straight into
`$GHIDRA_INSTALL_DIR/Ghidra/Extensions/<clone-directory-name>/` — as a plain
directory, not a zip you import through the GUI. One gotcha worth knowing
before you hit it: **the installed folder (and the separate `dist/*.zip` the
build also produces) is named after your local clone directory**, not after
the extension itself — there's no `settings.gradle` pinning a project name,
so Gradle falls back to the containing folder's name. Cloning into the
default `reverse-engineering-assistant` directory is harmless either way
(Ghidra identifies the extension by the `name=ReVa` line inside
`extension.properties`, not by the folder name) — but if you rename the
clone to something else, that name is what you'll see under `Ghidra/Extensions/`
and in the dist zip's filename, which can be confusing when cross-checking
against the README.

## Activating the extension (GUI mode)

Per the README, activation is a **two-step, two-place** process — this part
could not be run hands-on in this environment (no display available), so
treat it as documented-not-observed, same caveat `05-automation-scripting`
gave every GUI-only claim:

1. In the **Project view** (the initial Ghidra window, before opening a
   program): **File → Configure**, click "Configure all plugins" (top-right,
   plug icon), check **"ReVa Application Plugin"**. This is the
   application-level plugin — it manages the MCP server for the whole Ghidra
   session and survives closing/reopening individual CodeBrowser tools.
2. In a **CodeBrowser tool** (after opening a program): **File → Configure**,
   "Configure all plugins" again, check **"ReVa Plugin"**. Then **File → Save
   Tool** so this stays checked by default for future sessions. This is the
   tool-level plugin — it tracks your current location/selection and
   provides ReVa's UI panel.

Once both are enabled, the MCP server listens on `http://localhost:8080/mcp/message`
by default (port configurable from Ghidra's project-view settings).

## Connecting an AI client

**Claude Code** (the client ReVa's own README recommends):

```sh
claude mcp add --scope user --transport http ReVa -- http://localhost:8080/mcp/message
```

With Ghidra running and the plugins enabled, `claude`'s `/mcp` command should
list `ReVa` as connected. To stop Claude Code prompting for every tool call,
`/permissions` and add a rule for `mcp__ReVa` — see guide 3 and guide 4 for
why you should scope that permission narrowly rather than blanket-allowing
it against every binary.

**VS Code** (via its built-in MCP client):

```json
{
  "mcp": {
    "servers": {
      "ReVa Assistant": { "type": "http", "url": "http://localhost:8080/mcp/message" }
    }
  }
}
```

## Headless mode (no GUI Ghidra needed)

This is a genuinely different install path, not just a flag: headless mode
ships as its own PyPI/`uv` package (`reverse-engineering-assistant`), not the
Ghidra extension above.

```sh
export GHIDRA_INSTALL_DIR=/path/to/ghidra_12.1.2_PUBLIC   # required
uv tool install reverse-engineering-assistant
claude mcp add --scope user ReVa -- mcp-reva
claude -p "Import /path/to/binary with ReVa and tell me how it works"
```

ReVa manages its own headless Ghidra project under `.reva/projects/` in the
current working directory — session-scoped and ephemeral by default, though
running `claude` again from the same directory reuses that project so you
can import several files into it. This is the natural mode for
`05-automation-scripting`-style batch/CI work — one process, no CodeBrowser,
no manual project management.

## Where configuration actually lives

Two settings categories, both readable/writable through Ghidra's normal
Options UI once the plugins are active:

- **"ReVa Server Options"** — port/host, `API Key Authentication Enabled`,
  `API Key`, `Allow Public Binding Without API Key`. Server binds to
  `127.0.0.1` by default; guide 4 covers what happens if you point it
  elsewhere.
- **"ReVa Tool Groups"** — one on/off toggle per tool group (`Core Analysis`,
  `Data & Types`, `Advanced Analysis`, `Diff`, `Annotations`, `Scripting`),
  all **on by default**. Guide 4 uses the `Scripting` toggle as the concrete
  mitigation for the prompt-injection gap guide 1 flagged as unaddressed
  everywhere in the field.

In headless mode there's no Options UI — the same settings are a
`.properties` file, one line per setting, `category.name` lowercased with
dots for spaces:

```properties
reva.server.options.server.port=9090
reva.server.options.api.key.authentication.enabled=false
reva.tool.groups.scripting=false
```

passed as `RevaHeadlessLauncher`'s config-file argument (see the extension's
own `ReVa/headless/CLAUDE.md` for the full property reference if you're
scripting against it directly rather than through the `mcp-reva` CLI).

---

**Self-check:** you built ReVa from source and it installed with no version
mismatch dialog. A teammate instead grabs the release zip from GitHub's
Releases page and installs *that* against the same 12.1.2 install — what
happens, and why does building from source sidestep it specifically for
*this* extension (i.e. why wouldn't the same trick be needed for, say,
`ghidra-amiga`)? → They'll hit the Extension Version Mismatch dialog,
because the release zip's `extension.properties` says `version=12.1` while
the running Ghidra is `12.1.2`, and Ghidra does an exact string match, not a
compatible-range check. Building from source sidesteps it because ReVa's
version string is a build-time placeholder filled in from
`$GHIDRA_INSTALL_DIR` — build against your real install and the two numbers
can't drift apart. That's specific to how ReVa's `extension.properties` is
templated; an extension that hardcodes its declared version (as
`ghidra-amiga`'s per-release build does, per Phase 6) doesn't get this
trick for free — for those, the version match is only as good as whichever
release the maintainer tagged for your exact Ghidra point release.
