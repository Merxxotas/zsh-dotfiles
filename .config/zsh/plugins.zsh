# =========================================================
# ~/.config/zsh/plugins.zsh - Minimalist Plugin Engine
# =========================================================

ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
  local repo="${1}"
  local name="${2}"
  local plugin_file="${3:-${name}.plugin.zsh}"
  local plugin_path="${ZPLUGINDIR}/${name}"

  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "[INFO] Installing plugin ${name}..."
    git clone --depth=1 --recurse-submodules --shallow-submodules "https://github.com/${repo}/${name}" "$plugin_path" \
      || { echo "[ERROR] Failed to install ${name}" >&2; return 1; }
  fi

  if [[ -f "${plugin_path}/${plugin_file}" ]]; then
    source "${plugin_path}/${plugin_file}"
  elif [[ -f "${plugin_path}/${name}.zsh" ]]; then
    source "${plugin_path}/${name}.zsh"
  elif [[ -f "${plugin_path}/${name}.plugin.zsh" ]]; then
    source "${plugin_path}/${name}.plugin.zsh"
  fi
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "[INFO] Updating ${dir:t}..."
    git -C "$dir" pull --ff-only && git -C "$dir" submodule update --init --recursive
  done
}

# Core Plugins
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load hlissner zsh-autopair autopair.zsh
_zplugin_load MichaelAquilina zsh-you-should-use you-should-use.plugin.zsh
_zplugin_load olets zsh-abbr zsh-abbr.zsh
_zplugin_load Aloxaf fzf-tab fzf-tab.plugin.zsh
_zplugin_load zdharma-continuum fast-syntax-highlighting fast-syntax-highlighting.plugin.zsh
