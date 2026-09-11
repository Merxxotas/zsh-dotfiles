# ZSH Dotfiles (Universal Modular Architecture)

A high-performance, modular, and supply-chain-hardened ZSH configuration suite. Designed for seamless portability across Linux distributions (Ubuntu, Debian, Arch Linux, Fedora, openSUSE, Alpine, RHEL/Rocky) and macOS.

[![CI - Lint](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/lint.yml)
[![CI - Debian & Ubuntu](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-debian-ubuntu.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-debian-ubuntu.yml)
[![CI - Arch, Fedora & openSUSE](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-arch-fedora-suse.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-arch-fedora-suse.yml)
[![CI - Enterprise, Alpine & Gentoo](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-enterprise-alpine-gentoo.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-enterprise-alpine-gentoo.yml)
[![Wiki](https://img.shields.io/badge/docs-GitHub_Wiki-blue.svg)](https://github.com/Merxxotas/zsh-dotfiles/wiki)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## Highlights at a Glance

* **Zero-Latency Startup (<30ms)**: Zero network calls on spawn; NVM/Node lazy-loaded; PNPM v11 global bin path resolution; compiled completion caching.
* **Strict XDG Compliance**: `$HOME` remains clean; configuration resides in `~/.config/zsh`, cache in `~/.cache/zsh`, state/history in `~/.local/state/zsh`.
* **Supply-Chain Hardened**: Zero `curl | sh`; all 8 plugins pinned to 40-character SHAs (`plugins.lock`); standalone binaries verified via SHA256 (`dependencies.lock`).
* **Contextual UI & Completion**: Oh-My-Posh prompt engine with user/root isolation, dynamic Vi-mode cursors, and FZF-Tab preview popups.
* **Universal Multimedia Suite**: Built-in CLI tools (`vconv`, `vdl`, `adl`, `vaudio`, `vcut`, `vgif`) powered by `ffmpeg` and `yt-dlp`.

---

## Quick Start

### 1. Installation

```bash
# Clone the repository
git clone https://github.com/Merxxotas/zsh-dotfiles.git ~/Projects/zsh-dotfiles
cd ~/Projects/zsh-dotfiles

# Run the universal installer
./install.sh
```

### Installation Modes

| Command | Purpose |
| :--- | :--- |
| `./install.sh` | **Standard Copy** (recommended for production servers) |
| `./install.sh -s` | **Symlink Mode** (file-by-file links, recommended for active dotfiles development) |
| `./install.sh -y --no-deps` | **Unattended Mode** (for Docker containers and CI pipelines) |
| `./install.sh --dry-run` | **Dry Run** (preview changes without writing to disk) |
| `./install.sh --list-backups` | **List Snapshots** (backups are auto-created before any change) |
| `./install.sh --restore <id>` | **Restore Snapshot** (instant transactional rollback) |

---

## Daily Workflow Cheatsheet

### Top Keybindings

| Keybinding | Function | Description |
| :--- | :--- | :--- |
| `Ctrl + R` | Atuin Search | Interactive full-screen encrypted history search |
| `Tab` | FZF-Tab | Contextual popup completion with live preview |
| `Alt + S` | Magic Sudo | Toggle `sudo` on current command line or previous entry |
| `Ctrl + T` / `Ctrl + F` | FZF Search | Fuzzy file search with syntax-highlighted preview |
| `Esc` / `i` | Vi Modal | Toggle Normal (block cursor) and Insert (beam cursor) cursor |

### Core CLI Utilities

| Command | Example Usage | Action |
| :--- | :--- | :--- |
| `fuck` | `fuck` | Instant command auto-correction via `pay-respects` |
| `posh-theme` | `posh-theme [name]` | Interactive Oh-My-Posh theme switcher (150+ themes) |
| `take` | `take path/to/dir` | Create nested directory and navigate into it (`mkdir -p && cd`) |
| `extract` | `extract archive.tar.gz` | Universal batch archive extractor (`zip`, `tar`, `7z`, `rar`, multi-part/split archives) |
| `vdl` | `vdl "<url>" -q 1080` | Universal video downloader (YouTube, X, TikTok, Twitch, Reddit) |
| `adl` | `adl "<url>"` | High-fidelity 320kbps audio downloader with embedded art |
| `vconv` | `vconv input.webm mp4` | Video converter and batch transcoder (`-f` for stream copy) |
| `vcut` | `vcut video.mp4 01:00 02:30` | Lossless stream-copy trimming without re-encoding |
| `vgif` | `vgif video.mp4 anim.gif` | 2-pass high-quality animated GIF generator |

---

## Private Configuration (`local.zsh`)

To define host-specific tokens, credentials, or private aliases without committing them to Git:

```bash
cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
chmod 600 ~/.config/zsh/local.zsh
```

Supported API keys (e.g. `GIPHY_API_KEY`, `KLIPY_API_KEY`) and personal environment variables can be exported here safely.

---

## Verification and Testing

```bash
# Run syntax linting, security pattern checks, and offline test suite
make verify

# Run automated unit and integration tests (TS-01 to TS-06)
make test
```

---

## Documentation and Wiki

For full technical specifications, architecture diagrams, and comprehensive guides, consult the **[Official GitHub Wiki](https://github.com/Merxxotas/zsh-dotfiles/wiki)**:

| Chapter | Topic & Coverage |
| :---: | :--- |
| [**01**](https://github.com/Merxxotas/zsh-dotfiles/wiki/01-Architecture-and-XDG) | **[Architecture & XDG Compliance](https://github.com/Merxxotas/zsh-dotfiles/wiki/01-Architecture-and-XDG)** — Directory hierarchy, startup lifecycle, root fallback. |
| [**02**](https://github.com/Merxxotas/zsh-dotfiles/wiki/02-Installation-and-Deployment) | **[Installation & Deployment](https://github.com/Merxxotas/zsh-dotfiles/wiki/02-Installation-and-Deployment)** — Installer architecture, flags, symlink vs copy, transactional backups. |
| [**03**](https://github.com/Merxxotas/zsh-dotfiles/wiki/03-Dev-Environment-and-Tooling) | **[Dev Environment & Tooling](https://github.com/Merxxotas/zsh-dotfiles/wiki/03-Dev-Environment-and-Tooling)** — PNPM v11 bin resolution, NVM lazy loading, Bun, Cargo, Pay-Respects, Atuin. |
| [**04**](https://github.com/Merxxotas/zsh-dotfiles/wiki/04-Multimedia-Suite) | **[Multimedia Suite Manual](https://github.com/Merxxotas/zsh-dotfiles/wiki/04-Multimedia-Suite)** — Full operational manual for `vconv`, `vdl`, `adl`, `vaudio`, `vcut`, and `vgif`. |
| [**05**](https://github.com/Merxxotas/zsh-dotfiles/wiki/05-Themes-and-Prompt-Engine) | **[Themes & Prompt Engine](https://github.com/Merxxotas/zsh-dotfiles/wiki/05-Themes-and-Prompt-Engine)** — Oh-My-Posh engine, root vs user isolation, interactive `posh-theme` CLI. |
| [**06**](https://github.com/Merxxotas/zsh-dotfiles/wiki/06-Plugins-and-Keybindings) | **[Plugins & Keybindings](https://github.com/Merxxotas/zsh-dotfiles/wiki/06-Plugins-and-Keybindings)** — Pinned plugins, FZF-Tab contextual previews, shortcuts, abbreviations. |
| [**07**](https://github.com/Merxxotas/zsh-dotfiles/wiki/07-Testing-and-CI-CD) | **[Testing & CI/CD](https://github.com/Merxxotas/zsh-dotfiles/wiki/07-Testing-and-CI-CD)** — Offline test harness, unit/integration suites, multi-distro CI matrix. |
| [**08**](https://github.com/Merxxotas/zsh-dotfiles/wiki/08-Security-and-Supply-Chain) | **[Security & Supply Chain](https://github.com/Merxxotas/zsh-dotfiles/wiki/08-Security-and-Supply-Chain)** — Threat model, SHA lockfiles, API keys, secret isolation. |

---

## License

Distributed under the terms of the **[MIT License](LICENSE)**.
