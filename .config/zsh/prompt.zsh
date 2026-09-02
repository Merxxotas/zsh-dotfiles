# =========================================================
# ~/.config/zsh/prompt.zsh - Oh-My-Posh Engine & Theme Manager
# =========================================================

export VIRTUAL_ENV_DISABLE_PROMPT=1
FUNCNEST=100

THEME_DIR="${ZDOTDIR:-$HOME/.config/zsh}/themes"
CACHE_THEME_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-posh/themes"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
STATE_THEME_FILE="$STATE_DIR/current_theme"

mkdir -p "$THEME_DIR" "$CACHE_THEME_DIR" "$STATE_DIR" 2>/dev/null || true

_get_current_posh_theme() {
  if [[ -f "$STATE_THEME_FILE" ]]; then
    cat "$STATE_THEME_FILE"
  elif [[ $EUID -eq 0 ]]; then
    echo "tokyo"
  elif [[ -f "${ZDOTDIR:-$HOME/.config/zsh}/current_theme" ]]; then
    cat "${ZDOTDIR:-$HOME/.config/zsh}/current_theme"
  else
    echo "clean-detailed"
  fi
}

_init_posh_theme() {
  local theme="$(_get_current_posh_theme)"
  local config=""

  if [[ -f "$THEME_DIR/${theme}.omp.json" ]]; then
    config="$THEME_DIR/${theme}.omp.json"
  elif [[ -f "$CACHE_THEME_DIR/${theme}.omp.json" ]]; then
    config="$CACHE_THEME_DIR/${theme}.omp.json"
  elif [[ -f "$THEME_DIR/clean-detailed.omp.json" ]]; then
    config="$THEME_DIR/clean-detailed.omp.json"
  fi

  if command -v oh-my-posh >/dev/null 2>&1 && [[ -n "$config" ]]; then
    eval "$(oh-my-posh init zsh --config "$config")"
  fi
}

_init_posh_theme

posh-theme() {
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    echo "[ERROR] oh-my-posh is not installed." >&2
    return 1
  fi

  local theme="$1"

  # Sanitize extension if passed (e.g. if_tea.omp.json -> if_tea)
  theme="${theme%.omp.json}"
  theme="${theme%.json}"

  if [[ -z "$theme" ]]; then
    if command -v fzf >/dev/null 2>&1; then
      local raw_files=()
      [[ -d "$CACHE_THEME_DIR" ]] && raw_files+=("$CACHE_THEME_DIR"/*.omp.json(N:t))
      [[ -d "$THEME_DIR" ]] && raw_files+=("$THEME_DIR"/*.omp.json(N:t))

      local unique_themes=(${(u)${(@)raw_files%.omp.json}})

      theme=$(printf '%s\n' "${unique_themes[@]}" | fzf \
        --height=50% \
        --layout=reverse \
        --border=rounded \
        --prompt="Select Oh-My-Posh Theme: " \
        --header="Enter: Apply | ESC: Cancel")
    else
      echo "Usage: posh-theme <theme_name>"
      echo "Example: posh-theme if_tea"
      return 1
    fi
  fi

  [[ -z "$theme" ]] && return 0

  # Validate theme name (disallow traversal, slashes, or script characters)
  if [[ ! "$theme" =~ ^[A-Za-z0-9._-]+$ ]]; then
    echo "[ERROR] Invalid theme name: '$theme'" >&2
    return 1
  fi

  local target_file=""

  if [[ -f "$CACHE_THEME_DIR/${theme}.omp.json" ]]; then
    target_file="$CACHE_THEME_DIR/${theme}.omp.json"
  elif [[ -f "$THEME_DIR/${theme}.omp.json" ]]; then
    target_file="$THEME_DIR/${theme}.omp.json"
  else
    # Download into temporary staging file
    local tmp_file
    tmp_file="$(mktemp -t "posh_theme_${theme}.XXXXXX.json" 2>/dev/null || echo "/tmp/posh_theme_$$.json")"

    echo "[INFO] Downloading theme '$theme' from official Oh-My-Posh repository..."
    if ! curl -sLf "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$tmp_file"; then
      echo "[ERROR] Theme '$theme' not found in official repository." >&2
      rm -f "$tmp_file"
      return 1
    fi

    # Validate JSON integrity and strip transient_prompt
    if command -v python3 >/dev/null 2>&1; then
      if ! python3 -c '
import json, sys
path = sys.argv[1]
try:
    with open(path) as f:
        d = json.load(f)
    if "transient_prompt" in d:
        del d["transient_prompt"]
    with open(path, "w") as f:
        json.dump(d, f, indent=2)
except Exception as e:
    sys.exit(1)
' "$tmp_file" 2>/dev/null; then
        echo "[ERROR] Downloaded theme file is not valid JSON." >&2
        rm -f "$tmp_file"
        return 1
      fi
    fi

    # Test initialization with temporary file
    if ! oh-my-posh init zsh --config "$tmp_file" >/dev/null 2>&1; then
      echo "[ERROR] Theme '$theme' failed Oh-My-Posh initialization test." >&2
      rm -f "$tmp_file"
      return 1
    fi

    mkdir -p "$CACHE_THEME_DIR"
    mv -f "$tmp_file" "$CACHE_THEME_DIR/${theme}.omp.json"
    target_file="$CACHE_THEME_DIR/${theme}.omp.json"
    echo "[OK] Theme '$theme' downloaded and cached."
  fi

  # Persist selection atomically
  mkdir -p "$STATE_DIR"
  local tmp_state="$STATE_DIR/current_theme.tmp.$$"
  echo "$theme" > "$tmp_state"
  mv -f "$tmp_state" "$STATE_THEME_FILE"
  echo "$theme" > "${ZDOTDIR:-$HOME/.config/zsh}/current_theme" 2>/dev/null || true

  echo "[OK] Theme '$theme' applied and set as default."
  rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-posh/init."*.zsh 2>/dev/null || true
  eval "$(oh-my-posh init zsh --config "$target_file")"
}
