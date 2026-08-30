# =========================================================
# ~/.zshenv - Root Fallback ZDOTDIR Redirection
# =========================================================

# Fallback universal para TERM (resuelve duplicación de caracteres en Ghostty / Kitty sobre SSH)
if ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM="xterm-256color"
fi

# Redirección de ZDOTDIR al estándar XDG ~/.config/zsh
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
  export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
