# ZSH Dotfiles (Universal Modular Architecture)

A high-performance, modular, and minimalist ZSH configuration suite. Designed for portable deployment across Linux distributions (Ubuntu 24.04 LTS, Debian, Arch Linux, Fedora, RHEL/Rocky, openSUSE, Alpine, Gentoo) and macOS.

[![CI - Lint](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/lint.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/lint.yml)
[![CI - Debian & Ubuntu](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-debian-ubuntu.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-debian-ubuntu.yml)
[![CI - Arch, Fedora & openSUSE](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-arch-fedora-suse.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-arch-fedora-suse.yml)
[![CI - Enterprise, Alpine & Gentoo](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-enterprise-alpine-gentoo.yml/badge.svg)](https://github.com/Merxxotas/zsh-dotfiles/actions/workflows/ci-enterprise-alpine-gentoo.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Core Architecture and Features

- **XDG Base Directory Compliance**: All configuration files, history, and cache reside inside `$HOME/.config/zsh`, `$HOME/.local/state/zsh`, and `$HOME/.cache/zsh`.
- **FZF-Tab Dynamic Previews**: Interactive menu completion using FZF with contextual preview windows:
  - `kill` / `pkill`: Real-time process table (`PID`, `%CPU`, `%MEM`, command line).
  - Directory navigation (`cd`, `z`): Directory tree preview with `eza`.
  - File operations (`bat`, `nvim`, `cat`): Syntax-highlighted file preview with `bat`.
  - Git operations (`git checkout`, `git log`): Branch diff and commit graph inspection.
  - Environment variables: Dynamic parameter expansion inspection.
- **Universal Multimedia Suite (`media.zsh`)**:
  - `vconv`: Universal video transcoder and batch converter (`webm`, `mp4`, `mkv`, `avi`, `mov`).
  - `vdl`: Universal video downloader (YouTube, Twitter/X, TikTok, Instagram, Reddit, Twitch) in MP4 with metadata.
  - `adl`: Universal audio downloader into 320kbps MP3 with embedded thumbnails.
  - `vaudio`: Local video-to-MP3 audio extractor.
  - `vcut`: Instant lossless video trimming (`-c copy`) without re-encoding.
  - `vgif`: High-quality 2-pass animated GIF generator with optimized color palettes (`palettegen`).
- **Fish-Style Real-Time Abbreviations (`zsh-abbr`)**: Expands abbreviations upon pressing `Space`, keeping the command line explicit and recording complete commands in shell history.
- **Atuin Integration**: SQLite-backed shell history with encrypted synchronization, fuzzy search, and TUI exploration.
- **Oh-My-Posh Dual Theme Engine**: Offline prompt rendering with dynamic user distinction:
  - Standard User: `clean-detailed` (transient prompt disabled to avoid layout shifts).
  - Superuser (root): `tokyo` (root privileges and memory usage monitoring).
- **Interactive Theme Switcher (`posh-theme`)**: Built-in CLI command to search, download, and persist 150+ official Oh-My-Posh themes.
- **Vi-Mode Modal Editing (`zsh-vi-mode`)**: Dynamic cursor shape switching (beam `|` in insert mode, block `█` in normal mode).
- **Magic Sudo (`Alt+S`)**: Quick prefixing and toggling of `sudo` on current buffer or previous history entry.
- **Didactic Alias Reminder (`zsh-you-should-use`)**: Inline reminders when running commands with configured aliases.
- **Intelligent Autopair (`zsh-autopair`)**: Automatic closing, jumping, and backspace deletion for quotes and brackets.
- **Universal Helpers**:
  - `take <dir>`: Recursive directory creation and immediate navigation (`mkdir -p && cd`).
  - `extract <file(s)>`: Universal single and batch archive extractor (`zip`, `tar.gz`, `7z`, `rar`, Google Drive split ZIPs).

---

## Directory Layout

```
~/.config/zsh/
├── .zshenv                # Environment variables, consolidated PATH, XDG base paths, TERM fallback
├── .zshrc                 # Core shell options, history, compinit, module loader
├── aliases.zsh            # Resilient aliases, abbreviations (zsh-abbr), git, safe ls & clear
├── bindings.zsh           # Vi-mode configuration, Magic Sudo (Alt+S), Atuin hooks
├── dev-env.zsh            # Integrations: Atuin, NVM (lazy load), Bun, PNPM, Cargo, Homebrew, GCloud
├── fzf.zsh                # Fuzzy finder defaults and bat preview integration
├── fzf-tab.zsh            # Context-sensitive Tab completion rules and preview hooks
├── helpers.zsh            # Universal take() and multi-file extract() utilities
├── local.zsh.example      # Template for private host-specific variables and API keys
├── media.zsh              # Universal media suite: vconv, vdl, adl, vaudio, vcut, vgif
├── plugins.zsh            # Autonomous zero-overhead Git plugin loader and updater
├── prompt.zsh             # Oh-My-Posh engine and posh-theme CLI manager (150+ themes)
└── themes/
    ├── clean-detailed.omp.json
    ├── if_tea.omp.json
    └── tokyo.omp.json
```

---

## Multimedia Commands Guide

### Video Conversion (`vconv`)
```bash
# Convert a single video to MP4 (H.264 + AAC high quality)
vconv video.webm mp4

# Convert multiple files in batch
vconv *.webm mp4

# Fast container switch without re-encoding (-c copy)
vconv -f video.mkv mp4
```

### Video and Audio Download (`vdl` & `adl`)
```bash
# Download video from YouTube, Twitter/X, TikTok, Instagram, Reddit, Twitch in MP4
vdl "https://www.youtube.com/watch?v=..."
vdl "https://x.com/user/status/..."

# Limit maximum resolution to 720p or 1080p
vdl "https://www.youtube.com/watch?v=..." -q 720

# Download full playlist
vdl "https://www.youtube.com/playlist?list=..." -p

# Download audio only in 320kbps MP3 with embedded thumbnail and metadata
adl "https://www.youtube.com/watch?v=..."
```

### Audio Extraction, Trimming and GIF Creation
```bash
# Extract audio track to MP3 from local video
vaudio video.mp4
vaudio *.webm

# Lossless video trimming between timestamps (start end [output])
vcut video.mp4 00:01:30 00:02:45 clip.mp4

# High-quality animated GIF generation (input [output] [fps=15] [width=480])
vgif video.mp4 animation.gif 15 480
```

---

## Keybindings Reference

| Keybinding | Function | Description |
| :--- | :--- | :--- |
| `Ctrl + R` | `atuin-search` | Interactive full-screen Atuin history search |
| `Tab` | `fzf-tab` | Contextual interactive completion popup |
| `Alt + S` | `magic-sudo` | Prepend / remove `sudo` to current command buffer |
| `Ctrl + F` | `_fzf_file_no_hidden` | Fuzzy file search excluding hidden files |
| `Ctrl + T` | `fzf-file-widget` | Universal fuzzy file search with syntax preview |
| `Ctrl + ->` / `Ctrl + <-` | `forward-word` / `backward-word` | Word boundary navigation |
| `Alt + ->` | `forward-word` | Accept partial auto-suggestion token |
| `Ctrl + \` | `autosuggest-toggle` | Toggle auto-suggestions visibility |
| `Esc` | `vi-cmd-mode` | Enter normal Vi mode (cursor block) |
| `i` / `a` | `vi-insert` | Enter insert mode (cursor beam) |

---

## Abbreviations and Aliases

| Shorthand | Target Command | Behavior |
| :--- | :--- | :--- |
| `gs` | `git status -s` | Auto-expanded via space, alias fallback |
| `gss` | `git status` | Standard git status |
| `gco` | `git checkout` | Auto-expanded via space |
| `ga` / `gaa` | `git add` / `git add --all` | Auto-expanded via space |
| `gc` / `gca` | `git commit -m` / `git commit --amend` | Auto-expanded via space |
| `gp` / `gpl` | `git push` / `git pull` | Auto-expanded via space |
| `gb` / `gd` | `git branch` / `git diff` | Auto-expanded via space |
| `lg` | `lazygit` | Interactive git TUI |
| `pac` / `pacu` | `sudo pacman -S` / `sudo pacman -Syu` | Package management shorthand |
| `sc` / `scu` | `sudo systemctl` / `systemctl --user` | Service management |
| `take <dir>` | `mkdir -p <dir> && cd <dir>` | Directory creation and traversal |
| `extract <file(s)>` | `tar / unzip / 7z / unrar / unzstd` | Automatic single and batch archive extraction |
| `posh-theme` | `posh-theme [name]` | Interactive theme selector and downloader (150+ themes) |

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Merxxotas/zsh-dotfiles.git ~/Projects/zsh-dotfiles
cd ~/Projects/zsh-dotfiles
```

### 2. Execute the Automated Installer

Standard copy deployment (with automated backup of previous configurations):

```bash
./install.sh
```

Symlink deployment (recommended for dotfiles development so changes link directly to repo):

```bash
./install.sh -s
```

Unattended mode for CI and automated server provisioning:

```bash
./install.sh -y
```

---

## Private Configuration & API Keys (`local.zsh`)

To configure machine-specific environment variables, private aliases, or third-party API keys without committing them to Git:

```bash
cp ~/.config/zsh/local.zsh.example ~/.config/zsh/local.zsh
```

### Supported API Keys

1. **Giphy API Key (`GIPHY_API_KEY`)**:
   - Used by CLI media tools and GIF engines.
   - Obtain a free API key at [Giphy Developers Portal](https://developers.giphy.com/).
2. **Klipy API Key (`KLIPY_API_KEY`)**:
   - Used for sticker and clip search integrations.
   - Obtain a key at [Klipy Developer Portal](https://klipy.co/).

Add them inside `~/.config/zsh/local.zsh`:

```zsh
export GIPHY_API_KEY="your_actual_key_here"
export KLIPY_API_KEY="your_actual_key_here"
```

`~/.config/zsh/local.zsh` is automatically loaded by `.zshrc` and ignored by Git.

---


## Theme Management (`posh-theme`)

To switch or explore Oh-My-Posh themes interactively:

```bash
# Interactive selection via FZF (includes 150+ official themes)
posh-theme

# Direct activation by theme name
posh-theme if_tea
posh-theme clean-detailed
posh-theme tokyo
posh-theme catppuccin
```

---

## Plugin Updates

To update all installed ZSH plugins from upstream repositories:

```bash
zplugin-update
```

---

## Verification and Testing

For test scenarios and verification criteria, refer to:
[TEST_SCENARIOS.md](./TEST_SCENARIOS.md)

---

## Continuous Integration

This repository includes a multi-distribution CI matrix running on GitHub Actions:

- **Debian / Ubuntu**: Tests against Ubuntu 24.04 LTS, Ubuntu 22.04 LTS, Debian 12 (Bookworm), and Debian Testing.
- **Arch / Fedora / openSUSE**: Tests against Arch Linux, Fedora Latest, and openSUSE Leap 15.6.
- **Enterprise / Alpine / Gentoo**: Tests against Rocky Linux 9, AlmaLinux 9, Alpine Linux 3.21/3.20.
- **Static Analysis**: Validates syntax (`zsh -n`) and shell scripting standards (`shellcheck`).

---

## License

This project is licensed under the terms of the MIT License.
