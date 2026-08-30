# =========================================================
# ~/.config/zsh/fzf.zsh - Universal FZF Configuration
# =========================================================

# Detección de fd / fdfind (Ubuntu)
if command -v fd >/dev/null 2>&1; then
  export FZF_FD_CMD="fd"
elif command -v fdfind >/dev/null 2>&1; then
  export FZF_FD_CMD="fdfind"
else
  export FZF_FD_CMD="find"
fi

if [[ "$FZF_FD_CMD" != "find" ]]; then
  export FZF_DEFAULT_COMMAND="$FZF_FD_CMD --type f --hidden --strip-cwd-prefix --exclude .git"
else
  export FZF_DEFAULT_COMMAND="find . -type f"
fi
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="▶ "
  --preview-window=right:65%:wrap:border-left
'

# Preview command con bat o batcat
if command -v bat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
elif command -v batcat >/dev/null 2>&1; then
  export _FZF_PREVIEW_CMD='batcat --color=always --style=plain,numbers --line-range=:500 {}'
else
  export _FZF_PREVIEW_CMD='cat {}'
fi
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

_fzf_file_no_hidden() {
  local cmd result
  if [[ "$FZF_FD_CMD" != "find" ]]; then
    cmd="$FZF_FD_CMD --type f --strip-cwd-prefix --exclude .git"
  else
    cmd="find . -type f -not -path '*/.*'"
  fi
  result=$(eval "$cmd" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden
