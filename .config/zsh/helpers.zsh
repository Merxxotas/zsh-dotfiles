# =========================================================
# ~/.config/zsh/helpers.zsh - Super Helper Functions
# =========================================================

# 1. take: crea uno o varios directorios y entra inmediatamente en el último
take() {
  mkdir -p "$@" && cd "$_";
}

# 2. extract: descompresor universal inteligente
extract() {
  if [ -z "$1" ]; then
    echo "Uso: extract <archivo.(tar.gz|zip|rar|7z|tar.xz|zst|...)>"
    return 1
  fi

  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *.tar.xz)    tar xf "$1"      ;;
      *.xz)        xz -d "$1"       ;;
      *.tar.zst)   tar --zstd -xf "$1" ;;
      *.zst)       unzstd "$1"      ;;
      *)           echo "Formato desconocido para '$1'" ;;
    esac
  else
    echo "'$1' no es un archivo válido"
  fi
}
