# =========================================================
# ~/.config/zsh/plugins.zsh - Deterministic Offline Plugin Loader
# =========================================================

# Store plugins in XDG_DATA_HOME (outside config and repository)
ZPLUGINDIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"

# Support fallback to legacy path if already present
if [[ ! -d "$ZPLUGINDIR" && -d "${ZDOTDIR:-$HOME/.config/zsh}/plugins" ]]; then
  ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"
fi

_ZSH_MISSING_PLUGINS=()

_zplugin_load() {
  local name="${1}"
  local entrypoint="${2:-${name}.plugin.zsh}"
  local plugin_path=""

  if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/${name}" ]]; then
    plugin_path="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/${name}"
  elif [[ -d "${ZDOTDIR:-$HOME/.config/zsh}/plugins/${name}" ]]; then
    plugin_path="${ZDOTDIR:-$HOME/.config/zsh}/plugins/${name}"
  elif [[ -d "$ZPLUGINDIR/${name}" ]]; then
    plugin_path="$ZPLUGINDIR/${name}"
  fi

  if [[ -n "$plugin_path" ]]; then
    if [[ -f "${plugin_path}/${entrypoint}" ]]; then
      source "${plugin_path}/${entrypoint}"
      return 0
    elif [[ -f "${plugin_path}/${name}.plugin.zsh" ]]; then
      source "${plugin_path}/${name}.plugin.zsh"
      return 0
    elif [[ -f "${plugin_path}/${name}.zsh" ]]; then
      source "${plugin_path}/${name}.zsh"
      return 0
    fi
  fi

  _ZSH_MISSING_PLUGINS+=("$name")
}

# Explicit Plugin Installer from Lockfile (Zero network during normal startup)
zplugin-install() {
  local lockfile=""
  for candidate in \
    "${ZDOTDIR:-$HOME/.config/zsh}/plugins.lock" \
    "${ZDOTDIR:-$HOME/.config/zsh}/../../plugins.lock" \
    "$HOME/Projects/zsh-dotfiles/plugins.lock" \
    "/etc/zsh-dotfiles/plugins.lock"; do
    if [[ -f "$candidate" ]]; then
      lockfile="$candidate"
      break
    fi
  done

  if [[ -z "$lockfile" || ! -f "$lockfile" ]]; then
    echo "[ERROR] plugins.lock file not found." >&2
    return 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "[ERROR] git is required to install plugins." >&2
    return 1
  fi

  mkdir -p "$ZPLUGINDIR"
  local success=0
  local failed=0

  while IFS=$'\t' read -r name repo commit entrypoint || [[ -n "$name" ]]; do
    [[ -z "$name" || "$name" =~ ^[[:space:]]*# ]] && continue

    if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
      echo "  [ERROR] Invalid commit SHA for $name: '$commit'" >&2
      failed=$((failed + 1))
      continue
    fi

    local plugin_path="${ZPLUGINDIR}/${name}"
    echo "[INFO] Installing/verifying plugin '$name' (${commit:0:7})..."

    if [[ ! -d "$plugin_path" ]]; then
      if git clone --quiet "https://github.com/${repo}.git" "$plugin_path" 2>/dev/null; then
        if git -C "$plugin_path" checkout --detach --quiet -- "$commit" 2>/dev/null; then
          echo "  [OK] Installed $name at $commit"
          success=$((success + 1))
        else
          echo "  [ERROR] Failed to checkout commit $commit for $name" >&2
          rm -rf "$plugin_path"
          failed=$((failed + 1))
        fi
      else
        echo "  [ERROR] Failed to clone $repo" >&2
        failed=$((failed + 1))
      fi
    else
      # Verify existing plugin commit
      local current_commit
      current_commit="$(git -C "$plugin_path" rev-parse HEAD 2>/dev/null || echo "")"
      if [[ "$current_commit" == "$commit"* ]]; then
        echo "  [OK] $name is up to date ($current_commit)"
        success=$((success + 1))
      else
        echo "  [INFO] Syncing $name to locked commit $commit..."
        git -C "$plugin_path" fetch --quiet origin 2>/dev/null || true
        if git -C "$plugin_path" checkout --detach --quiet -- "$commit" 2>/dev/null; then
          echo "  [OK] Checked out $commit"
          success=$((success + 1))
        else
          echo "  [WARN] Failed to switch commit for $name" >&2
          failed=$((failed + 1))
        fi
      fi
    fi
  done < "$lockfile"

  echo "[INFO] Plugin installation complete: $success verified/installed, $failed failed."
  if [[ $failed -gt 0 ]]; then
    return 1
  fi
}

zplugin-update() {
  echo "[INFO] Synchronizing plugins with plugins.lock..."
  zplugin-install
}

# --- Load Configured Plugins from Local Cache ---
_zplugin_load zsh-autosuggestions zsh-autosuggestions.zsh
_zplugin_load zsh-history-substring-search zsh-history-substring-search.zsh
_zplugin_load zsh-vi-mode zsh-vi-mode.plugin.zsh
_zplugin_load zsh-autopair autopair.zsh
_zplugin_load zsh-you-should-use you-should-use.plugin.zsh
_zplugin_load zsh-abbr zsh-abbr.zsh
_zplugin_load fzf-tab fzf-tab.plugin.zsh
_zplugin_load fast-syntax-highlighting fast-syntax-highlighting.plugin.zsh

# Notify in interactive shell if plugins are missing (without blocking startup)
if [[ ${#_ZSH_MISSING_PLUGINS[@]} -gt 0 && -t 1 && -o interactive ]]; then
  echo "[INFO] Missing ${#_ZSH_MISSING_PLUGINS[@]} ZSH plugin(s). Run 'zplugin-install' to install."
fi
