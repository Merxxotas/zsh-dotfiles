# =========================================================
# ~/.config/zsh/prompt.zsh - Oh-My-Posh Engine & Theme Manager
# =========================================================

export VIRTUAL_ENV_DISABLE_PROMPT=1
FUNCNEST=100

THEME_DIR="${ZDOTDIR:-$HOME/.config/zsh}/themes"
CACHE_THEME_DIR="$HOME/.cache/oh-my-posh/themes"
mkdir -p "$THEME_DIR"

_get_current_posh_theme() {
  if [[ -f "${ZDOTDIR:-$HOME/.config/zsh}/current_theme" ]]; then
    cat "${ZDOTDIR:-$HOME/.config/zsh}/current_theme"
  elif [[ $EUID -eq 0 ]]; then
    echo "tokyo"
  else
    echo "clean-detailed"
  fi
}

_init_posh_theme() {
  local theme="$(_get_current_posh_theme)"
  local theme_file="$THEME_DIR/${theme}.omp.json"

  if command -v oh-my-posh >/dev/null 2>&1; then
    if [[ -f "$theme_file" ]]; then
      eval "$(oh-my-posh init zsh --config "$theme_file")"
    elif [[ -f "$CACHE_THEME_DIR/${theme}.omp.json" ]]; then
      eval "$(oh-my-posh init zsh --config "$CACHE_THEME_DIR/${theme}.omp.json")"
    elif [[ -f "$THEME_DIR/clean-detailed.omp.json" ]]; then
      eval "$(oh-my-posh init zsh --config "$THEME_DIR/clean-detailed.omp.json")"
    fi
  fi
}

_init_posh_theme

posh-theme() {
  local theme="$1"
  local theme_dir="${ZDOTDIR:-$HOME/.config/zsh}/themes"
  local cache_dir="$HOME/.cache/oh-my-posh/themes"
  mkdir -p "$theme_dir"

  # Sanitize extension if passed (e.g. if_tea.omp.json -> if_tea)
  theme="${theme%.omp.json}"
  theme="${theme%.json}"

  if [[ -z "$theme" ]]; then
    if command -v fzf >/dev/null 2>&1; then
      local all_themes=()
      if [[ -d "$cache_dir" ]]; then
        all_themes+=($(ls -1 "$cache_dir" 2>/dev/null | grep '\.omp\.json$' | sed 's/\.omp\.json$//'))
      fi
      if [[ -d "$theme_dir" ]]; then
        all_themes+=($(ls -1 "$theme_dir" 2>/dev/null | grep '\.omp\.json$' | sed 's/\.omp\.json$//'))
      fi

      local unique_themes=($(printf '%s\n' "${all_themes[@]}" | sort -u))

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

  # 1. If present in Oh-My-Posh cache, copy to local themes directory
  if [[ ! -f "$theme_dir/${theme}.omp.json" && -f "$cache_dir/${theme}.omp.json" ]]; then
    command cp "$cache_dir/${theme}.omp.json" "$theme_dir/${theme}.omp.json"
  fi

  # 2. If not found locally or in cache, download from official repository
  if [[ ! -f "$theme_dir/${theme}.omp.json" ]]; then
    echo "[INFO] Downloading theme '$theme' from Oh-My-Posh official repository..."
    if curl -sLf "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$theme_dir/${theme}.omp.json"; then
      echo "[OK] Theme '$theme' downloaded successfully."
    else
      echo "[ERROR] Theme '$theme' not found in official repository."
      rm -f "$theme_dir/${theme}.omp.json"
      return 1
    fi
  fi

  # Remove transient_prompt to prevent visual layout shifts
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json
try:
    with open('$theme_dir/${theme}.omp.json') as f:
        d = json.load(f)
    if 'transient_prompt' in d:
        del d['transient_prompt']
    with open('$theme_dir/${theme}.omp.json', 'w') as f:
        json.dump(d, f, indent=2)
except Exception:
    pass
" 2>/dev/null || true
  fi

  echo "$theme" > "${ZDOTDIR:-$HOME/.config/zsh}/current_theme"
  echo "[OK] Theme '$theme' applied and set as default."

  eval "$(oh-my-posh init zsh --config "$theme_dir/${theme}.omp.json")"
}
