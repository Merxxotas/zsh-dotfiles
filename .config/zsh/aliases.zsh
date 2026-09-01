# =========================================================
# ~/.config/zsh/aliases.zsh - Aliases & Abbreviations
# =========================================================

# --- Git & System Aliases (Compatible with you-should-use) ---
alias gs='git status -s'
alias gss='git status'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpl='git pull'
alias gco='git checkout'
alias gb='git branch'
alias gd='git diff'
alias lg='lazygit'
alias pac='sudo pacman -S'
alias pacs='pacman -Ss'
alias pacu='sudo pacman -Syu'
alias yay='paru -S'
alias sc='sudo systemctl'
alias scu='systemctl --user'

# --- Real-Time Expansion Abbreviations (zsh-abbr) ---
if command -v abbr >/dev/null 2>&1; then
  abbr -S gs="git status -s" >/dev/null 2>&1
  abbr -S gss="git status" >/dev/null 2>&1
  abbr -S ga="git add" >/dev/null 2>&1
  abbr -S gaa="git add --all" >/dev/null 2>&1
  abbr -S gc="git commit -m" >/dev/null 2>&1
  abbr -S gca="git commit --amend" >/dev/null 2>&1
  abbr -S gp="git push" >/dev/null 2>&1
  abbr -S gpl="git pull" >/dev/null 2>&1
  abbr -S gco="git checkout" >/dev/null 2>&1
  abbr -S gb="git branch" >/dev/null 2>&1
  abbr -S gd="git diff" >/dev/null 2>&1
  abbr -S lg="lazygit" >/dev/null 2>&1
  abbr -S pac="sudo pacman -S" >/dev/null 2>&1
  abbr -S pacs="pacman -Ss" >/dev/null 2>&1
  abbr -S pacu="sudo pacman -Syu" >/dev/null 2>&1
  abbr -S yay="paru -S" >/dev/null 2>&1
  abbr -S sc="sudo systemctl" >/dev/null 2>&1
  abbr -S scu="systemctl --user" >/dev/null 2>&1
fi

compdef eza=ls 2>/dev/null

unalias ls 2>/dev/null
ls() {
  case "$*" in
    *-la*|*-al*|*-lha*|*-lah*|*-alh*|*-ahl*|*-hla*|*-hal*)
      command eza -aghHliS --icons --git --group-directories-first "$@" ;;
    *)
      command eza -lH --icons --group-directories-first --git "$@" ;;
  esac
}

# --- Directory Listings ---
alias ll='eza -aghHliS --icons --git --group-directories-first'
alias la='eza -lah --icons --git'
alias lt='eza --tree --icons --git'
alias lt1='eza --tree --icons --git --level=1'
alias lt2='eza --tree --icons --git --level=2'
alias lt3='eza --tree --icons --git --level=3'
alias lt4='eza --tree --icons --git --level=4'
alias lt5='eza --tree --icons --git --level=5'

# --- Core Utilities ---
alias cat='bat'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias vim='nvim'
alias cp='/usr/local/bin/cpg -g'
alias mv='/usr/local/bin/mvg -g'
alias -- -='cd -'

# --- Navigation and Network Utilities ---
alias weather='curl wttr.in'
alias weather1='weathr'
alias speedtest='cloudflare-speed-cli'
alias spotify_player='KITTY_WINDOW_ID=1 TERM=xterm-kitty spotify_player'

# --- Formatted Git Log ---
alias glog='PAGER="less -F -X" git log'
alias gadog='PAGER="less -F -X" git log --all --decorate --oneline --graph'

# --- Yazi File Manager Wrapper (cd to navigated directory on exit) ---
y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# --- GitHub CLI: Context-Aware Account Selector by Path ---
gh() {
  case "$PWD/" in
    "$HOME/Documents/Projekt-Agency/"*)
      GH_CONFIG_DIR="$HOME/.config/gh-work" command gh "$@" ;;
    *)
      command gh "$@" ;;
  esac
}

# --- Vocabulary Engine on Session Start ---
if [[ -f "$HOME/.vocab" ]]; then
  chmod +x "$HOME/.vocab" 2>/dev/null
  "$HOME/.vocab" || true
fi

# --- Safe Clear Wrapper with Guaranteed Exit Code 0 ---
clean_clear() {
  command clear
  if [[ -f "$HOME/.vocab" ]]; then
    "$HOME/.vocab"
  fi
  return 0
}
alias clear=clean_clear
