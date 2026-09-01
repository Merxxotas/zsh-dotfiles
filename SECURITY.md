# Security Policy

## 1. Threat Model and Supply Chain Security

The **ZSH Dotfiles** suite implements strict supply chain integrity principles:

1. **Zero Remote Execution During Startup**: Normal shell startup performs zero network requests and executes only verified local code.
2. **Deterministic Artifact Verification**:
   - All third-party plugins are pinned to immutable 40-character commit SHAs in [`plugins.lock`](./plugins.lock).
   - Standalone binary dependencies (`yt-dlp`, `oh-my-posh`, `atuin`) are pinned to verified release versions with SHA256 checksums in [`dependencies.lock`](./dependencies.lock).
   - No unverified `curl | sh` or floating `latest` tags are used during installation.
3. **Transactional Backups & Safe Permissions**:
   - Configurations are backed up into timestamped snapshots before any modification.
   - Private configuration files (`local.zsh`) are assigned strict permissions (`0600`) and ignored by Git.

---

## 2. Supported Versions

Security updates and critical fixes are applied to the `main` branch.

| Branch | Supported |
| :--- | :---: |
| `main` | :white_check_mark: Yes |
| `< 2.0.0` | :x: No |

---

## 3. Reporting a Vulnerability

If you discover a security vulnerability in this project:

1. Please **do not** open a public GitHub issue.
2. Submit a private advisory via [GitHub Security Advisories](https://github.com/Merxxotas/zsh-dotfiles/security/advisories) or contact the maintainer directly.
3. Include details on how to reproduce the issue, affected platforms, and any potential mitigations.
4. You will receive an initial response within 48 hours, and critical fixes will be prioritized.
