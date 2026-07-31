# Exercise: Installation Verify

No sample program for this one — the "sample" is your own Ghidra install.
Covers [`01-installation-setup.md`](../../01-installation-setup.md).

1. Confirm you have a 64-bit **JDK 21** on `PATH` or `JAVA_HOME` (`java
   -version`; if both are set, `JAVA_HOME` wins).
2. Launch Ghidra (`ghidraRun` / `ghidraRun.bat`) and let the Project Window
   open with no errors.
3. Hover any toolbar icon in the Project Window and press **F1**. Confirm a
   help page opens for that specific item (not just the help TOC).
4. Without opening a project, locate `support/analyzeHeadless` (or
   `analyzeHeadless.bat`) under your Ghidra install directory. You don't need
   to run it — just confirm it exists (it's covered properly in
   `05-automation-scripting`).

**Check yourself:** if step 1 shows a JDK below 21, or `ghidraRun` prompts you
for a JDK path, what do you check first?
