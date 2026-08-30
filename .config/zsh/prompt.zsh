# =========================================================
# ~/.config/zsh/prompt.zsh - Oh-My-Posh Local Themes
# =========================================================

export VIRTUAL_ENV_DISABLE_PROMPT=1
FUNCNEST=100

THEME_DIR="$ZDOTDIR/themes"

if command -v oh-my-posh >/dev/null 2>&1; then
  if [[ $EUID -eq 0 ]]; then
    # Usuario ROOT -> Tema Tokyo local
    eval "$(oh-my-posh init zsh --config "$THEME_DIR/tokyo.omp.json")"
  else
    # Usuario MERXX -> Tema Clean Detailed local (sin transient_prompt)
    eval "$(oh-my-posh init zsh --config "$THEME_DIR/clean-detailed.omp.json")"
  fi
fi
