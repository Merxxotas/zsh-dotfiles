# =========================================================
# ~/.config/zsh/prompt.zsh - Oh-My-Posh & Theme Manager
# =========================================================

export VIRTUAL_ENV_DISABLE_PROMPT=1
FUNCNEST=100

THEME_DIR="${ZDOTDIR:-$HOME/.config/zsh}/themes"
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
    elif [[ -f "$THEME_DIR/clean-detailed.omp.json" ]]; then
      eval "$(oh-my-posh init zsh --config "$THEME_DIR/clean-detailed.omp.json")"
    else
      eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.omp.json)"
    fi
  fi
}

_init_posh_theme

posh-theme() {
  local theme="$1"
  local theme_dir="${ZDOTDIR:-$HOME/.config/zsh}/themes"
  mkdir -p "$theme_dir"

  if [[ -z "$theme" ]]; then
    if command -v fzf >/dev/null 2>&1; then
      local popular_themes=(
        "clean-detailed" "tokyo" "catppuccin" "catppuccin_mocha" "dracula"
        "agnoster" "jandedobbeleer" "space" "atomic" "bubbles" "half-life"
        "material" "pure" "rudolfs-dark" "star" "night-owl" "nord" "powerlevel10k_rainbow"
        "negligible" "pure" "slim" "sonicboom" "takuya" "tiptool" "whys"
      )
      local local_themes=($(ls -1 "$theme_dir" 2>/dev/null | sed 's/\.omp\.json$//'))
      local all_themes=($(printf '%s\n' "${local_themes[@]}" "${popular_themes[@]}" | sort -u))

      theme=$(printf '%s\n' "${all_themes[@]}" | fzf \
        --height=45% \
        --layout=reverse \
        --border=rounded \
        --prompt="Select Oh-My-Posh Theme: " \
        --header="Enter: Apply | ESC: Cancel")
    else
      echo "Usage: posh-theme <theme_name>"
      echo "Local themes: $(ls -1 "$theme_dir" | sed 's/\.omp\.json$//' | tr '\n' ' ')"
      return 1
    fi
  fi

  [[ -z "$theme" ]] && return 0

  if [[ ! -f "$theme_dir/${theme}.omp.json" ]]; then
    echo "[INFO] Downloading theme '$theme' from Oh-My-Posh official repository..."
    if curl -sLf "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$theme_dir/${theme}.omp.json"; then
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
      echo "[OK] Theme '$theme' downloaded successfully."
    else
      echo "[ERROR] Theme '$theme' not found."
      rm -f "$theme_dir/${theme}.omp.json"
      return 1
    fi
  fi

  echo "$theme" > "${ZDOTDIR:-$HOME/.config/zsh}/current_theme"
  echo "[OK] Theme '$theme' applied and set as default."

  eval "$(oh-my-posh init zsh --config "$theme_dir/${theme}.omp.json")"
}
