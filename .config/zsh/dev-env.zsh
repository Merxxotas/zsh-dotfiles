# =========================================================
# ~/.config/zsh/dev-env.zsh - Dev Tools & Integrations
# =========================================================

# Atuin (Shell History Sync & Interactive Search)
if [ -f "$HOME/.atuin/bin/env" ]; then
  . "$HOME/.atuin/bin/env"
elif [ -d "/home/merxx/.atuin/bin" ]; then
  export PATH="/home/merxx/.atuin/bin:$PATH"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# Homebrew
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

# NVM (Node Version Manager)
if [ -f "/usr/share/nvm/init-nvm.sh" ]; then
  source /usr/share/nvm/init-nvm.sh
fi

# Zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# The Fuck
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

# Railway
[ -f "$HOME/.railway/env" ] && source "$HOME/.railway/env"

# Google Cloud SDK
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then
  . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then
  . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"
fi

# IntelliShell
export INTELLI_HOME="/home/merxx/.local/share/intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
if command -v intelli-shell >/dev/null 2>&1; then
  eval "$(intelli-shell init zsh)"
fi
