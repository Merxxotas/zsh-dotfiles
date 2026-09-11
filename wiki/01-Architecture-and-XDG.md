# 01 - Architecture and XDG Compliance

This document details the modular structure, startup lifecycle, and strict adherence to the XDG Base Directory specification.

---

## Modular Directory Structure

All files reside neatly within the XDG hierarchy:

```text
~/.config/zsh/
├── .zshenv                # Universal environment, consolidated deduplicated PATH, TERM fallback
├── .zshrc                 # Core shell options, history, compinit, module orchestrator
├── aliases.zsh            # Resilient aliases, abbreviations (zsh-abbr), git, safe ls & clear
├── bindings.zsh           # Vi-mode configuration, Magic Sudo (Alt+S), Atuin hooks
├── dev-env.zsh            # Integrations: Atuin, NVM (lazy load), Bun, PNPM, Cargo, Homebrew, Pay-Respects, IntelliShell
├── fzf.zsh                # Fuzzy finder defaults and bat preview integration
├── fzf-tab.zsh            # Context-sensitive Tab completion rules and preview hooks
├── helpers.zsh            # Universal take() and multi-file/multipart extract() utilities
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

## XDG Base Directory Mapping

| XDG Variable | Target Path | Purpose |
| :--- | :--- | :--- |
| `XDG_CONFIG_HOME` | `~/.config` | Configurations: `~/.config/zsh` |
| `XDG_DATA_HOME` | `~/.local/share` | Cloned plugins (`~/.local/share/zsh/plugins`), PNPM home |
| `XDG_CACHE_HOME` | `~/.cache` | Completion dump (`zcompdump`), Oh-My-Posh init caches |
| `XDG_STATE_HOME` | `~/.local/state` | Shell history (`~/.local/state/zsh/history`), theme state |

---

## Startup Lifecycle & The Root Fallback

Standard ZSH reads `~/.zshenv` first before any other file. To prevent polluting `$HOME` with `.zshrc`, `.zlogin`, etc., we use a minimalist root fallback in `~/.zshenv`:

```zsh
# Redirect ZDOTDIR to standard XDG path ~/.config/zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
  if [[ -f "$ZDOTDIR/.zshenv" ]]; then
    source "$ZDOTDIR/.zshenv"
  fi
fi
```

### Execution Flow:

1. **`~/.zshenv`** is read by ZSH. It sets `ZDOTDIR="$XDG_CONFIG_HOME/zsh"` and sources `$ZDOTDIR/.zshenv`.
2. **`$ZDOTDIR/.zshenv`** initializes XDG base directories, sets default `EDITOR="nvim"`, universal `TERM` fallback, and consolidates the system `$PATH` (deduplicated via `typeset -U path PATH`).
3. **`$ZDOTDIR/.zshrc`** is read next in interactive shells. It initializes history options, completion caching, and sources modular components in order.
4. **`$ZDOTDIR/local.zsh`** (if present) is loaded last to inject machine-specific secrets and overrides.
