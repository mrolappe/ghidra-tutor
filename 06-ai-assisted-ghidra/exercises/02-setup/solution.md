# Solution: Build and verify ReVa

## Part A

```sh
git clone https://github.com/cyberkaida/reverse-engineering-assistant.git
cd reverse-engineering-assistant
export GHIDRA_INSTALL_DIR=~/ghidra_12.1.2_PUBLIC
gradle install
```

**Actual output from this project's own research pass** (2026-07-31,
against a real `ghidra_12.1.2_PUBLIC` install, Gradle 8.8, Java 21):

```
Installed ReVa

BUILD SUCCESSFUL in 18s
9 actionable tasks: 9 executed
```

Reading the installed `extension.properties`:

```
name=ReVa
description=Reverse Engineering Assistant
author=CyberKaida
createdOn=
version=12.1.2
```

`version=12.1.2` — an exact match with the Ghidra install it was built
against. The checked-in source has `version=@extversion@`; Ghidra's own
`buildExtension.gradle` fills that placeholder in from
`$GHIDRA_INSTALL_DIR` at build time, which is why building against your own
install always produces a matching version string, whatever that version
happens to be.

## Part B

ReVa's published release zips are per-Ghidra-version builds, but as of the
version guide 1 evaluated, the release targeting this course's line
declares `version=12.1` — three digits shortened to two, not matching
`12.1.2` exactly. Ghidra's extension installer
(`ExtensionInstaller.validateExtensionVersion`) does a literal string
comparison, not a compatible-range check, so installing that zip through
the GUI against a `12.1.2` Ghidra pops an "Extension Version Mismatch"
dialog. The dialog isn't a hard block — "Install Anyway" is available — but
*Cancel* is the default button, and the whole point of Part A's source
build is not needing to click past a warning at all.

## Part C

The installed folder was named after the **local clone directory**, not
after `ReVa` or the GitHub repo name literally. This project's own test
clone (into a directory deliberately named `reva-build` to make the effect
obvious) produced:

```
$GHIDRA_INSTALL_DIR/Ghidra/Extensions/reva-build/
dist/ghidra_12.1.2_PUBLIC_20260731_reva-build.zip
```

Checking `settings.gradle` in the repo root: **it doesn't exist.** With no
`rootProject.name` pinned, Gradle's default project-naming rule kicks in —
the project name is the containing directory's basename. Clone into the
repo's default directory name (`reverse-engineering-assistant`) and that's
what you'll see under `Ghidra/Extensions/` instead.

## Check-yourself answer

The installed folder would have been named `my-reva-test` — same
mechanism, Gradle still derives the project name from the clone directory's
basename regardless of what that basename is. But Ghidra **would** still
correctly identify and load it as ReVa, because Ghidra resolves an
extension's identity from the `name=ReVa` line inside
`extension.properties`, not from the containing folder's name. The folder
name only affects where you look for it on disk and what the `dist/*.zip`
gets called — it has no bearing on how Ghidra's extension manager treats
the installed extension once it's there.
