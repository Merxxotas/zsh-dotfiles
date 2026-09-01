# =========================================================
# ~/.config/zsh/helpers.zsh - Universal Helper Functions
# =========================================================

# 1. take: Create one or multiple directories and navigate immediately into the last one
take() {
  if [ $# -eq 0 ]; then
    echo "Usage: take <dir> [dir2 ...]" >&2
    return 1
  fi
  mkdir -p "$@" && cd "$_" || return 1
}

# 2. extract: Universal single-file and batch archive extractor
extract() {
  if [ $# -eq 0 ]; then
    echo "Usage: extract <archive1> [archive2 ...]" >&2
    return 1
  fi

  local file
  local success=0
  local failed=0

  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo "[ERROR] '$file' is not a valid file" >&2
      failed=$((failed + 1))
      continue
    fi

    echo "[INFO] Extracting '$file'..."
    case "${file:l}" in
      *.tar.bz2|*.tbz2)   tar xjf "$file" ;;
      *.tar.gz|*.tgz)     tar xzf "$file" ;;
      *.tar.xz|*.txz)     tar xf "$file" ;;
      *.tar.zst)          tar --zstd -xf "$file" 2>/dev/null || zstd -dc "$file" | tar xf - ;;
      *.tar)              tar xf "$file" ;;
      *.bz2)              bunzip2 -k "$file" ;;
      *.gz)               gunzip -k "$file" 2>/dev/null || gzip -dc "$file" > "${file%.gz}" ;;
      *.xz)               unxz -k "$file" 2>/dev/null || xz -dc "$file" > "${file%.xz}" ;;
      *.zst)              unzstd -k "$file" ;;
      *.rar)              unrar x "$file" 2>/dev/null || 7z x "$file" ;;
      *.zip)              unzip -q -o "$file" 2>/dev/null || 7z x "$file" ;;
      *.7z|*.7z.001)      7z x "$file" ;;
      *.pax)              pax -r < "$file" ;;
      *.deb)              ar x "$file" ;;
      *.rpm)              rpm2cpio "$file" | cpio -idmv ;;
      *.iso)              7z x "$file" ;;
      *.cpio)             cpio -idmv < "$file" ;;
      *.z)                uncompress "$file" ;;
      *)
        if command -v 7z >/dev/null 2>&1; then
          7z x "$file"
        elif command -v bsdtar >/dev/null 2>&1; then
          bsdtar -xf "$file"
        else
          echo "[ERROR] Unknown format for '$file'" >&2
          failed=$((failed + 1))
          continue
        fi
        ;;
    esac

    if [ $? -eq 0 ]; then
      success=$((success + 1))
    else
      echo "[ERROR] Failed to extract '$file'" >&2
      failed=$((failed + 1))
    fi
  done

  if [ $failed -eq 0 ] && [ $success -gt 0 ]; then
    echo "[OK] Extracted $success archive(s)."
    return 0
  elif [ $success -eq 0 ] && [ $failed -gt 0 ]; then
    echo "[ERROR] Extracted 0 archive(s); $failed failed." >&2
    return 1
  else
    echo "[WARN] Extracted $success archive(s); $failed failed." >&2
    return 1
  fi
}
