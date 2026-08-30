# =========================================================
# ~/.config/zsh/bindings.zsh - Keybindings & Vi-Mode
# =========================================================

# Forma del cursor: Barra en inserción (|), Bloque en comando (█)
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# Función Magic Sudo: antepone 'sudo ' a la línea actual
magic-sudo() {
  [[ -z $BUFFER ]] && zle up-history
  if [[ $BUFFER != sudo\ * ]]; then
    BUFFER="sudo $BUFFER"
    CURSOR+=5
  else
    BUFFER="${BUFFER#sudo }"
    CURSOR=$((CURSOR >= 5 ? CURSOR - 5 : 0))
  fi
}
zle -N magic-sudo

# Hook de inicialización de Vi-Mode (se ejecuta DESPUÉS de que zsh-vi-mode carga)
zvm_after_init() {
  # --- Integración con Atuin ---
  if (( $+widgets[atuin-search] )); then
    bindkey '^r' atuin-search
    bindkey '^R' atuin-search
    bindkey -M viins '^r' atuin-search-viins
    bindkey -M vicmd '^r' atuin-search-vicmd
    bindkey -M vicmd '/' atuin-search
    bindkey -M viins '^[[A' atuin-up-search-viins
    bindkey -M vicmd '^[[A' atuin-up-search-vicmd
  elif (( $+widgets[_atuin_search_widget] )); then
    bindkey '^r' _atuin_search_widget
    bindkey '^R' _atuin_search_widget
  fi

  # --- Alt+S / Alt+s -> Magic Sudo ---
  bindkey '^[s' magic-sudo
  bindkey '^[S' magic-sudo

  # --- Ctrl+Right / Ctrl+Left -> Salto entre palabras ---
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word

  # --- Alt+Right -> Aceptar una palabra de la autosugerencia ---
  bindkey '^[^[[C' forward-word

  # --- Ctrl+F -> FZF selector de archivos (sin archivos ocultos) ---
  bindkey '^F' _fzf_file_no_hidden

  # --- Ctrl+\ -> Activar / desactivar autosugerencias ---
  bindkey '^\' autosuggest-toggle

  # --- Flechas Arriba/Abajo (fallback si no está atuin) ---
  if ! (( $+widgets[atuin-search] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
  else
    bindkey '^[[B' down-line-or-history
  fi
}
