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
- **Fish-Style Real-Time Abbreviations (`zsh-abbr`)**: Expands abbreviations upon pressing `Space`, keeping the command line explicit and recording complete commands in shell history.
- **Atuin Integration**: SQLite-backed shell history with encrypted synchronization, fuzzy search, and TUI exploration.
- **Oh-My-Posh Dual Theme Engine**: Offline prompt rendering with dynamic user distinction:
  - Standard User: `clean-detailed` (transient prompt disabled to avoid layout shifts).
  - Superuser (root): `tokyo` (root privileges and memory usage monitoring).
- **Interactive Theme Switcher (`posh-theme`)**: Built-in CLI command to search, download, and persist official Oh-My-Posh themes.
- **Vi-Mode Modal Editing (`zsh-vi-mode`)**: Dynamic cursor shape switching (beam `|` in insert mode, block `█` in normal mode).
- **Magic Sudo (`Alt+S`)**: Quick prefixing and toggling of `sudo` on current buffer or previous history entry.
- **Didactic Alias Reminder (`zsh-you-should-use`)**: Inline reminders when running commands with configured aliases.
- **Intelligent Autopair (`zsh-autopair`)**: Automatic closing, jumping, and backspace deletion for quotes and brackets.
- **Universal Helpers**:
  - `take <dir>`: Recursive directory creation and immediate navigation (`mkdir -p && cd`).
  - `extract <file>`: Universal archive extraction without format-specific flags.

---

## Directory Layout

```
~/.config/zsh/
├── .zshenv                # Environment variables, consolidated PATH, XDG base paths
├── .zshrc                 # Core shell options, history, compinit, module loader
├── aliases.zsh            # Abbreviations (zsh-abbr), git aliases, eza, yazi wrapper, gh switcher
├── bindings.zsh           # Vi-mode configuration, Magic Sudo (Alt+S), Atuin hooks
├── dev-env.zsh            # Integrations: Atuin, NVM, Bun, PNPM, Cargo, Homebrew, Google Cloud SDK
├── fzf.zsh                # Fuzzy finder defaults and bat preview integration
├── fzf-tab.zsh            # Context-sensitive Tab completion rules and preview hooks
├── helpers.zsh            # Universal take() and extract() utilities
├── plugins.zsh            # Autonomous zero-overhead Git plugin loader and updater
├── prompt.zsh             # Oh-My-Posh engine and posh-theme CLI manager
└── themes/
    ├── clean-detailed.omp.json
    └── tokyo.omp.json
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
| `extract <file>` | `tar / unzip / 7z / unrar / unzstd` | Automatic archive extraction |
| `posh-theme` | `posh-theme [name]` | Interactive theme selector and downloader |

---

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Merxxotas/zsh-dotfiles.git ~/Projects/zsh-dotfiles
cd ~/Projects/zsh-dotfiles
```

### 2. Execute the Automated Installer

```bash
./install.sh
```

For automated deployments or CI environments, run with the unattended flag:

```bash
./install.sh -y
```

The installer automatically detects the underlying operating system and sets up packages, symlinks, XDG directories, and default shell configurations.

---

## Theme Management (`posh-theme`)

To switch or explore Oh-My-Posh themes interactively:

```bash
# Interactive selection via FZF
posh-theme

# Direct activation by theme name
posh-theme catppuccin
posh-theme dracula
posh-theme clean-detailed
posh-theme tokyo
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
- **Arch / Fedora / openSUSE**: Tests against Arch Linux, Fedora Latest, and openSUSE Tumbleweed.
- **Enterprise / Alpine / Gentoo**: Tests against Rocky Linux 9, AlmaLinux 9, Alpine Linux, and Gentoo stage3.
- **Static Analysis**: Validates syntax (`zsh -n`) and shell scripting standards (`shellcheck`).

---

## License

This project is licensed under the terms of the MIT License.
