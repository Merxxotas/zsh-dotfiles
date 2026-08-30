# =========================================================
# ~/.config/zsh/fzf-tab.zsh - Supercharged Tab Completions
# =========================================================

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:*' switch-group ',' '.'

# 1. Procesos para kill / pkill
zstyle ':fzf-tab:complete:(kill|pkill):argument-rest' fzf-preview \
  'ps --pid=$word -o cmd --no-headers -w -w 2>/dev/null'
zstyle ':fzf-tab:complete:(kill|pkill):*' fzf-flags \
  '--preview-window=down:3:wrap'

# 2. Previews de Git (checkout, diff, log, show)
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff $word 2>/dev/null || git diff --color=always $word 2>/dev/null'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'git log --oneline --graph --color=always -n 10 $word 2>/dev/null'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git show --color=always $word 2>/dev/null'

# 3. Previews de Directorios (cd, zoxide) con eza tree
zstyle ':fzf-tab:complete:cd:*' fzf-preview \
  'eza -1 --color=always --icons --tree --level=2 $realpath 2>/dev/null || ls -la $realpath'
zstyle ':fzf-tab:complete:z:*' fzf-preview \
  'eza -1 --color=always --icons --tree --level=2 $realpath 2>/dev/null || ls -la $realpath'

# 4. Previews de Archivos (cat, bat, nvim, etc.)
zstyle ':fzf-tab:complete:(cat|bat|nvim|vim|nano):*' fzf-preview \
  'bat --color=always --style=plain,numbers --line-range=:300 $realpath 2>/dev/null || cat $realpath 2>/dev/null'

# 5. Previews de Systemd (systemctl status)
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview \
  'SYSTEMD_COLORS=1 systemctl status $word 2>/dev/null'

# 6. Previews de Variables de Entorno
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'

# 7. Previews de Man Pages
zstyle ':fzf-tab:complete:(\\|)man:*' fzf-preview \
  'man $word 2>/dev/null | col -bx | bat -l man -p --color=always 2>/dev/null'
