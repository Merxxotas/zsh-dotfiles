# =========================================================
# ~/.zshenv - Root Fallback ZDOTDIR Redirection
# =========================================================

# Universal TERM fallback (prevents character duplication over SSH from Ghostty / Kitty)
if ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM="xterm-256color"
fi

# Redirect ZDOTDIR to standard XDG path ~/.config/zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
  if [[ -f "$ZDOTDIR/.zshenv" ]]; then
    source "$ZDOTDIR/.zshenv"
  fi
fi
