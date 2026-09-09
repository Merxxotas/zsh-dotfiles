# Welcome to ZSH Dotfiles Wiki 🐚

Welcome to the central technical documentation and knowledge base for **ZSH Dotfiles (Universal Modular Architecture)**.

This wiki provides comprehensive architecture deep-dives, operational references, developer tooling guides, multimedia manuals, testing strategies, and supply-chain security specifications.

---

## 🗺️ System Architecture Overview

```text
+----------------------------------------------------------------------------------------------------+
|                                    ZSH Universal Modular Suite                                     |
+---------------------------------+----------------------------------+-------------------------------+
                                  |                                  |
                                  v                                  v
+---------------------------------+--+     +-------------------------+---+     +---------------------+
|        ~/.config/zsh/              |     |    Developer Tooling        |     |   Quality & Tests   |
| - .zshenv (XDG & Consolidated PATH)|     | - Modern PNPM v11 Bin Paths |     | - Offline Test Suite|
| - .zshrc (History & Compinit Cache)|     | - NVM Zero-Latency Loader   |     | - 6 Unit Test Suites|
| - prompt.zsh (Oh-My-Posh Engine)   |     | - Pay-Respects (fuck)       |     | - Multi-Distro CI   |
| - media.zsh (Universal Multimedia) |     | - IntelliShell AI & Atuin   |     | - Security Lockfiles|
+------------------------------------+     +-----------------------------+     +---------------------+
```

---

## ⚡ Quick Navigation

| Guide | Description & Coverage |
| :--- | :--- |
| **[[01. Architecture & XDG\|01-Architecture-and-XDG]]** | Modular directory layout, XDG Base Directory specification, and startup optimization (<30ms). |
| **[[02. Installation & Deployment\|02-Installation-and-Deployment]]** | Universal installer (`install.sh`), copy vs. symlink modes, non-interactive CI provisioning, and transactional backups. |
| **[[03. Dev Environment & Tooling\|03-Dev-Environment-and-Tooling]]** | Modern PNPM v11 bin resolution, NVM lazy loading, Bun, Cargo, Pay-Respects, and IntelliShell. |
| **[[04. Multimedia Suite\|04-Multimedia-Suite]]** | Universal video/audio conversion (`vconv`), downloader recipes (`vdl`, `adl`), trimming (`vcut`), and 2-pass GIF generator (`vgif`). |
| **[[05. Themes & Prompt Engine\|05-Themes-and-Prompt-Engine]]** | Oh-My-Posh engine, root (`tokyo`) vs. user (`clean-detailed`) prompt isolation, and interactive `posh-theme` CLI. |
| **[[06. Plugins & Keybindings\|06-Plugins-and-Keybindings]]** | Autonomous zero-overhead plugin manager, 40-char SHA pinning, FZF-tab context previews, and Vi-mode bindings. |
| **[[07. Testing & CI/CD\|07-Testing-and-CI-CD]]** | Offline automated test suite, unit & integration test harness, and multi-distribution GitHub Actions matrix. |
| **[[08. Security & Supply Chain\|08-Security-and-Supply-Chain]]** | Threat model, deterministic lockfiles (`plugins.lock`, `dependencies.lock`), secret isolation, and audit rules. |

---

## 🏛️ Architectural Philosophy

1. **Zero-Latency Startup (<30ms)**:
   All heavy runtimes (Node, NVM) use lazy loaders. The completion cache (`zcompdump`) is refreshed only once every 24 hours. Plugin loading executes without network dependencies.
2. **Pure XDG Compliance**:
   Zero clutter in `$HOME`. Configurations reside in `~/.config/zsh`, runtime state in `~/.local/state/zsh`, and cache files in `~/.cache/zsh`.
3. **Cross-Platform Portability**:
   Tested seamlessly across Debian, Ubuntu, Arch Linux, Fedora, openSUSE, Alpine, Gentoo, RHEL/Rocky, and macOS.
4. **Supply Chain Determinism**:
   All 8 ZSH plugins are locked to exact 40-character commit hashes in `plugins.lock`. Standalone binaries (`yt-dlp`, `oh-my-posh`, `atuin`) are pinned to validated release binaries with SHA256 verification in `dependencies.lock`.

---

## 🔗 Quick Links

* [📦 GitHub Repository](https://github.com/Merxxotas/zsh-dotfiles)
* [🏷️ Releases & Changelog](https://github.com/Merxxotas/zsh-dotfiles/releases)
* [🐛 Issue Tracker](https://github.com/Merxxotas/zsh-dotfiles/issues)
* [📜 MIT License](https://github.com/Merxxotas/zsh-dotfiles/blob/main/LICENSE)
