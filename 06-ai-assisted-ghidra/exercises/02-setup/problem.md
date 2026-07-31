# Exercise: Build and verify ReVa

Covers [`02-setup.md`](../../02-setup.md). Unlike most toolchain exercises
earlier in this course (vasm, cc65 — flagged "unverified, no toolchain
installed"), this one **was** actually run end to end in this project's own
research pass, using a real `~/ghidra_12.1.2_PUBLIC` install. Run it
yourself and confirm you get the same shape of result.

## Part A — build from source

1. Clone ReVa:

   ```sh
   git clone https://github.com/cyberkaida/reverse-engineering-assistant.git
   cd reverse-engineering-assistant
   ```

2. Set `GHIDRA_INSTALL_DIR` to point at your own Ghidra 12.1.2 install (not
   the user-settings directory — the actual install directory containing
   `Ghidra/Extensions/`) and build:

   ```sh
   export GHIDRA_INSTALL_DIR=/path/to/your/ghidra_12.1.2_PUBLIC
   gradle install
   ```

3. Find the installed extension under `$GHIDRA_INSTALL_DIR/Ghidra/Extensions/`
   and read its `extension.properties`. What version does it declare?

## Part B — compare against the release zip

4. Without installing it, download ReVa's latest release zip from its
   GitHub Releases page and inspect its `extension.properties` (`unzip -p
   <zip> "*/extension.properties"` — no need to actually unpack it
   anywhere).
5. What version does *that* one declare, and what would happen if you
   installed it via Ghidra's GUI extension manager against a 12.1.2 install
   instead of the source build from Part A?

## Part C — the clone-directory-name gotcha

6. Look at the name of the folder that got created under
   `Ghidra/Extensions/` in Part A. Does it match `ReVa`, the repository
   name, or something else? Why — check `settings.gradle` (or its absence)
   in the repo root for the answer, not just the observed behavior.

**Check yourself:** if you'd cloned the repo into a folder named `my-reva-test`
instead of the default, what would the installed extension folder under
`Ghidra/Extensions/` have been named — and would Ghidra still correctly
identify and load it as ReVa? Why does the folder name not matter for that
second question, even though it clearly did get derived from something?
