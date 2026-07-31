# Solution: Installation Verify

1. `java -version` should print `21` somewhere in the version string, and it
   must be a JDK (has `javac`), not a JRE-only install. If `JAVA_HOME` is set
   to something else, that's what `ghidraRun` will use — `PATH` loses.
2. No specific output to check beyond "no crash, no dialog asking for a Java
   path" — that dialog only appears when Ghidra *can't* find a supported JDK.
3. The F1 page should be scoped to the hovered item (e.g. hovering the New
   Project icon opens the "Creating a Project" topic, not the help
   contents root). If it opens the generic TOC instead, you likely hovered
   empty toolbar space rather than the icon itself.
4. Typical location: `<GhidraInstallDir>/support/analyzeHeadless` (Linux/
   macOS) or `support\analyzeHeadless.bat` (Windows) — a shell/batch script,
   not a binary.

**Check yourself — answer:** `JAVA_HOME`. It takes priority over `PATH` when
Ghidra's launch script looks for a JDK, so a stale or wrong `JAVA_HOME` will
override an otherwise-correct `PATH` entry silently.
