# =========================================================
# ~/.config/zsh/dev-env.zsh - Universal Dev Tools
# =========================================================

# Atuin (Shell History Sync & Interactive Search)
if [ -f "$HOME/.atuin/bin/env" ]; then
  . "$HOME/.atuin/bin/env"
fi

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# Homebrew (Linux / macOS)
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
elif [ -f "/opt/homebrew/bin/brew" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv zsh)"
fi

# NVM (Node Version Manager) - Zero-Latency Lazy Loader
if [ -d "$HOME/.nvm" ] || [ -f "/usr/share/nvm/init-nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  _load_nvm() {
    unset -f nvm node npm npx yarn pnpm bun 2>/dev/null
    if [ -f "/usr/share/nvm/init-nvm.sh" ]; then
      source /usr/share/nvm/init-nvm.sh
    elif [ -s "$NVM_DIR/nvm.sh" ]; then
      \. "$NVM_DIR/nvm.sh"
    fi
  }
  nvm()  { _load_nvm; nvm "$@"; }
  node() { _load_nvm; node "$@"; }
  npm()  { _load_nvm; npm "$@"; }
  npx()  { _load_nvm; npx "$@"; }
fi

# Zoxide (Smart cd Replacement)
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Pay Respects (CLI Auto-Correction, replacing thefuck)
if command -v pay-respects >/dev/null 2>&1; then
  eval "$(pay-respects zsh --alias fuck --nocnf)"
elif command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi

# Railway CLI
[ -f "$HOME/.railway/env" ] && source "$HOME/.railway/env"

# Google Cloud SDK (Common System & User Paths)
for gcloud_dir in \
  "$HOME/google-cloud-sdk" \
  "/usr/lib/google-cloud-sdk" \
  "/opt/google-cloud-sdk" \
  "/usr/local/google-cloud-sdk" \
  "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk" \
  "$HOME/Downloads/google-cloud-sdk"; do
  if [ -d "$gcloud_dir" ]; then
    [ -f "$gcloud_dir/path.zsh.inc" ] && . "$gcloud_dir/path.zsh.inc"
    [ -f "$gcloud_dir/completion.zsh.inc" ] && . "$gcloud_dir/completion.zsh.inc"
    break
  fi
done


# IntelliShell
export INTELLI_HOME="$HOME/.local/share/intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
if command -v intelli-shell >/dev/null 2>&1; then
  eval "$(intelli-shell init zsh)"
fi

# --- AI Agent & Git Workspace Safety Guards ---
# Prevents accidental repository initialization in $HOME (~).
# Upstream AI tools (e.g. gentle-shell / gentle-ai review commands) can invoke 'git init'
# when executed directly within $HOME without an explicit project boundary.
gentle-shell() {
  if [[ -z "${GENTLE_ALLOW_HOME:-}" && "$PWD" == "$HOME" ]]; then
    echo "[ERROR] Cannot run gentle-shell directly in \$HOME (~)." >&2
    echo "[INFO] Navigate to a project workspace directory first (e.g. cd ~/Projects/<repo>)." >&2
    echo "[HINT] Set GENTLE_ALLOW_HOME=1 to override if intentional." >&2
    return 1
  fi
  command gentle-shell "$@"
}

gentle-ai() {
  case "$1" in
    doctor|version|--version|-v|--help|-h|help|update|telemetry|restore)
      command gentle-ai "$@"
      ;;
    *)
      if [[ -z "${GENTLE_ALLOW_HOME:-}" && "$PWD" == "$HOME" ]]; then
        local subcmd="${1:-workspace}"
        echo "[ERROR] Cannot run 'gentle-ai $subcmd' directly in \$HOME (~)." >&2
        echo "[INFO] Navigate to a project workspace directory first (e.g. cd ~/Projects/<repo>)." >&2
        echo "[HINT] Set GENTLE_ALLOW_HOME=1 to override if intentional." >&2
        return 1
      fi
      command gentle-ai "$@"
      ;;
  esac
}

git() {
  if [[ "$1" == "init" && -z "${GIT_ALLOW_HOME_INIT:-}" ]]; then
    local target="${2:-$PWD}"
    if [[ "$target" == "." ]]; then
      target="$PWD"
    fi
    if [[ "$target" == "$HOME" || ( "$PWD" == "$HOME" && $# -le 1 ) || "$target" == "~" ]]; then
      echo "[ERROR] Refusing to initialize a Git repository directly in \$HOME (~)." >&2
      echo "[INFO] Navigate to or specify a project workspace directory first." >&2
      echo "[HINT] Set GIT_ALLOW_HOME_INIT=1 to override if intentional." >&2
      return 1
    fi
  fi
  command git "$@"
}
