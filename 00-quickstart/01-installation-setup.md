# Installation & Setup

## Requirements

- **JDK 21, 64-bit** (a full JDK, not just a JRE). Free LTS builds work fine —
  Eclipse Temurin or Amazon Corretto are common choices.
- Windows 10 (build 1809+), Linux, or macOS 10.13+.
- Python 3.9–3.14 only if you plan to use the Debugger or PyGhidra later —
  not needed for this quickstart.

## Download & install

Ghidra has **no installer**. Get the zip from the
[GitHub releases page](https://github.com/NationalSecurityAgency/ghidra/releases)
(latest stable at the time of writing: **12.1.2**) and extract it wherever you
like. That's the whole install — removing Ghidra later just means deleting
the directory.

## First launch

From the extracted directory, run:

- Windows: `ghidraRun.bat`
- Linux/macOS: `./ghidraRun`

The launch script looks for a JDK on `PATH`, or at `JAVA_HOME` if that's set
(`JAVA_HOME` wins if both are present). If it can't find a supported version,
it prompts you to enter a JDK directory manually — have your JDK 21 install
path ready the first time.

## macOS: Gatekeeper

macOS may quarantine Ghidra's prebuilt native components on first launch.
Before extracting the zip, run:

```sh
xattr -d com.apple.quarantine ghidra_<version>_<date>.zip
```

(Alternative: rebuild the native components locally — see "Building Native
Components" in Ghidra's own `GettingStarted` doc if you'd rather not touch
quarantine attributes.)

## Getting help inside Ghidra

- **F1** over any window/menu/component opens context help for that item.
- `Help → Contents` opens the full indexed help — this is the same
  documentation set these guides are checked against, shipped with your copy.

## Headless mode (pointer only)

`support/analyzeHeadless` runs Ghidra without a GUI — importing, analyzing,
and scripting from the command line. Useful for batch processing; covered
properly in `05-automation-scripting`. Not needed to follow this module.

---

**Self-check:** if `ghidraRun` complains it can't find a supported JDK even
though you just installed one, what's the first thing to check? → Whether
`JAVA_HOME` (if set) points at that JDK — it takes priority over `PATH`.
