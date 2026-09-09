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

## Keybindings Table

| Keybinding | Widget | Description |
| :--- | :--- | :--- |
| `Ctrl + R` | `atuin-search` | Interactive full-screen Atuin history search |
| `Tab` | `fzf-tab` | Contextual interactive completion popup |
| `Alt + S` | `magic-sudo` | Prepend or remove `sudo` dynamically |
| `Ctrl + F` | `_fzf_file_no_hidden` | Search files excluding hidden directories |
| `Ctrl + T` | `fzf-file-widget` | Search files with bat syntax preview |
| `Ctrl + ->` / `Ctrl + <-` | `forward-word` / `backward-word` | Navigate between words |
| `Alt + ->` | `forward-word` | Accept partial auto-suggestion word |
| `Ctrl + \` | `autosuggest-toggle` | Toggle auto-suggestions visibility |
| `Esc` | `vi-cmd-mode` | Enter Normal Vi mode (block cursor) |
| `i` / `a` | `vi-insert` | Enter Insert Vi mode (beam cursor) |

---

## Didactic Reminders (`zsh-you-should-use`)

When typing full commands that have defined abbreviations or aliases (e.g. typing `git status -s` instead of `gs`), the shell provides an inline educational notification suggesting the shorthand.
