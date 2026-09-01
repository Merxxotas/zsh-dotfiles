# =========================================================
# ~/.config/zsh/.zshenv - Universal Environment & PATH
# =========================================================

# Universal TERM fallback (prevents character duplication over SSH from Ghostty / Kitty)
if ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM="xterm-256color"
fi

# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Default Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Manpager with bat / batcat (Debian/Ubuntu compatibility)
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# GPG TTY (only in interactive terminal)
if [ -t 0 ]; then
  export GPG_TTY="$(tty 2>/dev/null)"
fi

# Deduplicate PATH entries automatically
typeset -U path PATH

# Consolidated Universal PATH
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.atuin/bin"
  $path
)

# Bun & PNPM
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && path=("$BUN_INSTALL/bin" $path)

export PNPM_HOME="$XDG_DATA_HOME/pnpm"
[ -d "$PNPM_HOME" ] && path=("$PNPM_HOME" $path)

# Cargo environment
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

