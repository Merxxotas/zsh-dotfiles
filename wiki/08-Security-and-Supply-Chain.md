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
   Host-specific tokens, credentials, and API keys are strictly isolated from version control:
   * Template provided at `~/.config/zsh/local.zsh.example`.
   * Initialize your private configuration:
     ```bash
     cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
     chmod 600 ~/.config/zsh/local.zsh
     ```
   * The file is automatically sourced by `.zshrc` if present, with strict file permission enforcement (`0600`).
   * Permanently ignored by Git via `.gitignore`.

---

## Supported Third-Party API Keys

Add third-party API credentials safely into `~/.config/zsh/local.zsh`:

### 1. Giphy API (`GIPHY_API_KEY`)
* Used by CLI multimedia tools and animated GIF engines.
* Obtain a free developer key at the [Giphy Developers Portal](https://developers.giphy.com/).

### 2. Klipy API (`KLIPY_API_KEY`)
* Used for sticker and clip search integrations.
* Obtain a developer key at the [Klipy Developer Portal](https://klipy.co/).

```zsh
# ~/.config/zsh/local.zsh
export GIPHY_API_KEY="your_actual_key_here"
export KLIPY_API_KEY="your_actual_key_here"
```

---

## Automated Security Audits

The repository enforces supply chain integrity via `make lint`:
* Static code analysis via `shellcheck`.
* Regex-based ban on unauthenticated remote piping (`curl | sh`).
* Verification of 40-character SHAs across all entries in `plugins.lock`.
* Valid JSON structure check for all prompt themes.
