# =========================================================
# ~/.config/zsh/bindings.zsh - Keybindings & Vi-Mode
# =========================================================

# Cursor Shape: Beam in Insert Mode (|), Solid Block in Normal/Visual Mode (█)
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# Magic Sudo Widget: Prepends/Removes 'sudo ' on Current Buffer
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

# Vi-Mode Post-Initialization Hook (Executes AFTER zsh-vi-mode loads)
zvm_after_init() {
  # --- Atuin Shell History Integration ---
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

  # --- Ctrl+Right / Ctrl+Left -> Word Boundary Navigation ---
  bindkey '^[[1;5C' forward-word
  bindkey '^[[1;5D' backward-word

  # --- Alt+Right -> Accept Single Token of Auto-Suggestion ---
  bindkey '^[^[[C' forward-word

  # --- Ctrl+F -> FZF File Finder (Excluding Hidden Files) ---
  bindkey '^F' _fzf_file_no_hidden

  # --- Ctrl+\ -> Toggle Auto-Suggestions Visibility ---
  bindkey '^\' autosuggest-toggle

  # --- Up/Down Navigation (Fallback when Atuin is not installed) ---
  if ! (( $+widgets[atuin-search] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
  else
    bindkey '^[[B' down-line-or-history
  fi
}
