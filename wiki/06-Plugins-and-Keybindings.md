# 06 - Plugins and Keybindings

Plugins and keyboard shortcuts provide a modern terminal workflow without the bloat of traditional plugin frameworks (Oh-My-Zsh, Presto).

---

## Pinned Plugins (`plugins.lock`)

All plugins are cloned to `$XDG_DATA_HOME/zsh/plugins/` and checked out at pinned 40-character commit hashes:

1. `zsh-users/zsh-autosuggestions`
2. `zsh-users/zsh-syntax-highlighting`
3. `zsh-users/zsh-completions`
4. `Aloxaf/fzf-tab`
5. `jeffreytse/zsh-vi-mode`
6. `hlissner/zsh-autopair`
7. `MichaelAquilina/zsh-you-should-use`
8. `olets/zsh-abbr`

To install or sync plugins to their locked hashes:
```bash
zplugin-install
```

---

## Interactive Completion Previews (`fzf-tab`)

`fzf-tab.zsh` configures contextual rich previews during Tab completion:

* **Process Management (`kill`, `pkill`)**: Displays real-time process details including PID, CPU%, MEM%, and full command arguments.
* **Directory Navigation (`cd`, `z`)**: Previews directory structure and tree via `eza --tree --level=2`.
* **File Operations (`bat`, `nvim`, `cat`)**: Displays syntax-highlighted file contents with line numbers using `bat`.
* **Git Operations (`git checkout`, `git log`, `git diff`)**: Shows commit graphs, branch status, and inline file diffs.
* **Environment Variables**: Dynamically expands and displays variable values.

---

## Keybindings Table

| Keybinding | Widget | Description |
| :--- | :--- | :--- |
| `Ctrl + R` | `atuin-search` | Interactive full-screen Atuin history search |
| `Tab` | `fzf-tab` | Contextual interactive completion popup |
| `Alt + S` | `magic-sudo` | Dynamically prepend or remove `sudo` on current buffer |
| `Ctrl + F` | `_fzf_file_no_hidden` | Search files excluding hidden directories |
| `Ctrl + T` | `fzf-file-widget` | Search files with bat syntax preview |
| `Ctrl + ->` / `Ctrl + <-` | `forward-word` / `backward-word` | Navigate between words |
| `Alt + ->` | `forward-word` | Accept partial auto-suggestion word |
| `Ctrl + \` | `autosuggest-toggle` | Toggle auto-suggestions visibility |
| `Esc` | `vi-cmd-mode` | Enter Normal Vi mode (block cursor) |
| `i` / `a` | `vi-insert` | Enter Insert Vi mode (beam cursor) |

---

## Abbreviations & Resilient Aliases

Configured across `aliases.zsh` and `zsh-abbr`. Abbreviations expand in real time upon pressing `Space`, keeping commands explicit in shell history.

| Shorthand | Target Command | Description |
| :--- | :--- | :--- |
| `gs` | `git status -s` | Compact Git status |
| `gss` | `git status` | Full Git status |
| `gco` | `git checkout` | Checkout branch or file |
| `ga` / `gaa` | `git add` / `git add --all` | Stage specific or all files |
| `gc` / `gca` | `git commit -m` / `git commit --amend` | Commit changes |
| `gp` / `gpl` | `git push` / `git pull` | Push/pull from remote |
| `gb` / `gd` | `git branch` / `git diff` | Branch list / Git diff |
| `lg` | `lazygit` | Interactive terminal Git TUI |
| `pac` / `pacu` | `sudo pacman -S` / `sudo pacman -Syu` | Arch Linux package management |
| `sc` / `scu` | `sudo systemctl` / `systemctl --user` | Systemd service management |
| `take <dir>` | `mkdir -p <dir> && cd <dir>` | Create directory and immediately navigate inside |
| `extract <file(s)>` | `tar / unzip / 7z / unrar / unzstd` | Automatic single and batch archive extraction |
| `fuck` | `pay-respects zsh --alias fuck --nocnf` | Instant command auto-correction |
| `posh-theme` | `posh-theme [name]` | Interactive Oh-My-Posh theme selector |

---

## Didactic Reminders (`zsh-you-should-use`)

When typing full commands that have defined abbreviations or aliases (e.g. typing `git status -s` instead of `gs`), the shell provides an inline educational notification suggesting the shorthand.
