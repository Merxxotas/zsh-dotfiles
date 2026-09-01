# =========================================================
# ~/.config/zsh/.zshenv - Universal Environment & PATH
# =========================================================

# Universal TERM fallback (prevents character duplication over SSH from Ghostty / Kitty)
if ! infocmp "$TERM" >/dev/null 2>&1; then
  export TERM="xterm-256color"
fi

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Default Editor
export EDITOR="nvim"
export VISUAL="nvim"

# Manpager with bat / batcat (Debian/Ubuntu compatibility)
if command -v bat >/dev/null 2>&1; then
  export MANPAGER="bat -l man -p"
elif command -v batcat >/dev/null 2>&1; then
  export MANPAGER="batcat -l man -p"
fi

# GPG TTY
export GPG_TTY=$(tty)

# Consolidated Universal PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.atuin/bin:$PATH"

# Bun & PNPM
export BUN_INSTALL="$HOME/.bun"
[ -d "$BUN_INSTALL/bin" ] && export PATH="$BUN_INSTALL/bin:$PATH"

export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

# Cargo environment
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# System and Application Variables
export LIBVIRT_DEFAULT_URI="qemu:///system"


export QML2_IMPORT_PATH="$HOME/.local/lib/qt6/qml"
export CAELESTIA_LIB_DIR="$HOME/.local/lib/caelestia"
export ENDCORD_VOICE_OPUS_MODE="audio"
