# =========================================================
# ~/.config/zsh/prompt.zsh - Oh-My-Posh & Theme Switcher
# =========================================================

export VIRTUAL_ENV_DISABLE_PROMPT=1
FUNCNEST=100

THEME_DIR="${ZDOTDIR:-$HOME/.config/zsh}/themes"
mkdir -p "$THEME_DIR"

# Determinar tema actual (preferencia guardada o por defecto según UID)
_get_current_posh_theme() {
  if [[ -f "${ZDOTDIR:-$HOME/.config/zsh}/current_theme" ]]; then
    cat "${ZDOTDIR:-$HOME/.config/zsh}/current_theme"
  elif [[ $EUID -eq 0 ]]; then
    echo "tokyo"
  else
    echo "clean-detailed"
  fi
}

# Inicializar Oh-My-Posh con el tema actual
_init_posh_theme() {
  local theme="$(_get_current_posh_theme)"
  local theme_file="$THEME_DIR/${theme}.omp.json"

  if command -v oh-my-posh >/dev/null 2>&1; then
    if [[ -f "$theme_file" ]]; then
      eval "$(oh-my-posh init zsh --config "$theme_file")"
    elif [[ -f "$THEME_DIR/clean-detailed.omp.json" ]]; then
      eval "$(oh-my-posh init zsh --config "$THEME_DIR/clean-detailed.omp.json")"
    else
      # Fallback remoto si no existen temas locales
      eval "$(oh-my-posh init zsh --config https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.omp.json)"
    fi
  fi
}

_init_posh_theme

# =========================================================
# Comando posh-theme: Selector interactivo y gestor de temas
# =========================================================
posh-theme() {
  local theme="$1"
  local theme_dir="${ZDOTDIR:-$HOME/.config/zsh}/themes"
  mkdir -p "$theme_dir"

  # Si no se proporciona argumento, abrir selector FZF interactivo
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
        --prompt="🎨 Selecciona un tema de Oh-My-Posh: " \
        --header="Presiona Enter para aplicar | ESC para cancelar")
    else
      echo "Uso: posh-theme <nombre_tema>"
      echo "Temas locales disponibles: $(ls -1 "$theme_dir" | sed 's/\.omp\.json$//' | tr '\n' ' ')"
      return 1
    fi
  fi

  [[ -z "$theme" ]] && return 0

  # Descargar el tema de GitHub si no existe en local
  if [[ ! -f "$theme_dir/${theme}.omp.json" ]]; then
    echo "📥 Descargando tema '$theme' desde el repositorio oficial de Oh-My-Posh..."
    if curl -sLf "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json" -o "$theme_dir/${theme}.omp.json"; then
      # Limpiar transient_prompt si python3 está disponible
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
      echo "✓ Tema '$theme' descargado y guardado en local."
    else
      echo "❌ Error: El tema '$theme' no fue encontrado en https://github.com/JanDeDobbeleer/oh-my-posh"
      rm -f "$theme_dir/${theme}.omp.json"
      return 1
    fi
  fi

  # Guardar la preferencia
  echo "$theme" > "${ZDOTDIR:-$HOME/.config/zsh}/current_theme"
  echo "✨ Tema '$theme' activado y guardado como predeterminado."

  # Recargar prompt en la sesión actual
  eval "$(oh-my-posh init zsh --config "$theme_dir/${theme}.omp.json")"
}
