# =========================================================
# ~/.config/zsh/.zshrc - Universal Super Profile
# =========================================================

# --- Historial XDG ---
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# --- Opciones Avanzadas ---
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_MINUS

# --- Desactivar resaltado molesto al pegar texto ---
zle_highlight=(paste:none)

# --- Sistema de Autocompletado ---
autoload -Uz compinit
compinit -u -d "$XDG_CACHE_HOME/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# --- Sourcing Universal de FZF (Arch, Ubuntu, Debian, Fedora, macOS) ---
if command -v fzf >/dev/null 2>&1; then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    # Arch / CachyOS / Fedora
    [[ -f /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
    # Ubuntu / Debian
    [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]] && source /usr/share/doc/fzf/examples/key-bindings.zsh
    [[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh
    # macOS Homebrew
    [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]] && source /usr/local/opt/fzf/shell/key-bindings.zsh
  fi
fi

# --- Módulos del Super Perfil ---
source "$ZDOTDIR/fzf.zsh"
source "$ZDOTDIR/helpers.zsh"
source "$ZDOTDIR/media.zsh"
source "$ZDOTDIR/plugins.zsh"
source "$ZDOTDIR/aliases.zsh"
source "$ZDOTDIR/bindings.zsh"
source "$ZDOTDIR/dev-env.zsh"
source "$ZDOTDIR/fzf-tab.zsh"
source "$ZDOTDIR/prompt.zsh"

# --- Configuración Privada Opcional ---
if [[ -f "$ZDOTDIR/local.zsh" ]]; then
  source "$ZDOTDIR/local.zsh"
fi
