# 08 - Security and Supply Chain

This dotfiles suite follows zero-trust and supply-chain security principles.

---

## Core Security Safeguards

1. **No `curl | sh` Execution**:
   All installation scripts and runtime functions strictly forbid piping remote network downloads directly into shell interpreters. This is enforced via automated linter checks in `make lint`:
   ```bash
   ! grep -rnE 'curl\s+.*\|\s*(ba)?sh' install.sh .config/zsh/
   ```

2. **Deterministic Commit Pinning (`plugins.lock`)**:
   Plugins are never tracked to floating branch names (`master`/`main`). Each repository is locked to a 40-character hexadecimal SHA and verified upon cloning.

3. **Cryptographic Checksums (`dependencies.lock`)**:
   Standalone binaries (`yt-dlp`, `oh-my-posh`, `atuin`) are downloaded only with matching SHA256 checksum verification. Corrupted or altered downloads abort the installer immediately.

4. **Secret Isolation (`local.zsh`)**:
   Host-specific tokens, credentials, and API keys are stored in `~/.config/zsh/local.zsh`.
   * The file is enforced with `0600` permissions.
   * The file is included in `.gitignore` and never committed to version control.
