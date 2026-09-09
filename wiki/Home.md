# ZSH Dotfiles Knowledge Base & Wiki

Welcome to the official documentation and knowledge base for **ZSH Dotfiles (Universal Modular Architecture)**.

This wiki provides comprehensive architecture deep-dives, deployment patterns, operational manuals for multimedia and developer tooling, testing strategies, and security supply-chain specifications.

---

## Quick Navigation

| Section | Description |
| :--- | :--- |
| **[[01 Architecture and XDG|01-Architecture-and-XDG]]** | Modular directory layout, XDG Base Directory compliance, and startup lifecycle. |
| **[[02 Installation and Deployment|02-Installation-and-Deployment]]** | Universal installer (`install.sh`), copy vs symlink modes, automated provisioning, and backups. |
| **[[03 Dev Environment and Tooling|03-Dev-Environment-and-Tooling]]** | PNPM v11 bin resolution, NVM lazy loader, Bun, Cargo, Homebrew, Pay-Respects, and IntelliShell. |
| **[[04 Multimedia Suite|04-Multimedia-Suite]]** | Complete user manual for `vconv`, `vdl`, `adl`, `vaudio`, `vcut`, and `vgif`. |
| **[[05 Themes and Prompt Engine|05-Themes-and-Prompt-Engine]]** | Oh-My-Posh dual engine, user vs root prompt isolation, and interactive `posh-theme` CLI. |
| **[[06 Plugins and Keybindings|06-Plugins-and-Keybindings]]** | Autonomous zero-overhead plugin manager, FZF-tab context previews, and Vi-mode bindings. |
| **[[07 Testing and CI CD|07-Testing-and-CI-CD]]** | Offline automated test suite, unit and integration tests, and multi-distro GitHub Actions matrix. |
| **[[08 Security and Supply Chain|08-Security-and-Supply-Chain]]** | Threat modeling, deterministic lockfiles (`plugins.lock`, `dependencies.lock`), and audit rules. |

---

## Architectural Philosophy

1. **Zero-Latency Startup (<30ms)**:
   All heavy runtimes (Node, NVM) use lazy loaders. The completion cache (`zcompdump`) is refreshed only once every 24 hours. Plugin loading executes without network dependencies.
2. **Pure XDG Compliance**:
   Zero clutter in `$HOME`. Configurations reside in `~/.config/zsh`, runtime state in `~/.local/state/zsh`, and cache files in `~/.cache/zsh`.
3. **Cross-Platform Portability**:
   Tested seamlessly across Debian, Ubuntu, Arch Linux, Fedora, openSUSE, Alpine, Gentoo, RHEL/Rocky, and macOS.
4. **Supply Chain Determinism**:
   All 8 ZSH plugins are locked to exact 40-character commit hashes in `plugins.lock`. Standalone binaries (`yt-dlp`, `oh-my-posh`, `atuin`) are pinned to validated release binaries with SHA256 verification in `dependencies.lock`.
