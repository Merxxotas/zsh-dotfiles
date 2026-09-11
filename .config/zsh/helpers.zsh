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
  setopt local_options extended_glob
  if [ $# -eq 0 ]; then
    echo "Usage: extract <archive1> [archive2 ...]" >&2
    return 1
  fi

  local file
  local success=0
  local failed=0
  typeset -A processed_primaries

  _extract_single() {
    local target="$1"
    echo "[INFO] Extracting '$target'..."
    case "${target:l}" in
      *.tar.bz2|*.tbz2)   tar xjf "$target" ;;
      *.tar.gz|*.tgz)     tar xzf "$target" ;;
      *.tar.xz|*.txz)     tar xf "$target" ;;
      *.tar.zst)          tar --zstd -xf "$target" 2>/dev/null || zstd -dc "$target" | tar xf - ;;
      *.tar)              tar xf "$target" ;;
      *.bz2)              bunzip2 -k "$target" ;;
      *.gz)               gunzip -k "$target" 2>/dev/null || gzip -dc "$target" > "${target%.gz}" ;;
      *.xz)               unxz -k "$target" 2>/dev/null || xz -dc "$target" > "${target%.xz}" ;;
      *.zst)              unzstd -k "$target" ;;
      *.rar)              unrar x -o+ "$target" 2>/dev/null || 7z x -y "$target" ;;
      *.zip)              unzip -q -o "$target" 2>/dev/null || 7z x -y "$target" ;;
      *.7z|*.7z.[0-9]##)  7z x -y "$target" ;;
      *.pax)              pax -r < "$target" ;;
      *.deb)              ar x "$target" ;;
      *.rpm)              rpm2cpio "$target" | cpio -idmv ;;
      *.iso)              7z x -y "$target" ;;
      *.cpio)             cpio -idmv < "$target" ;;
      *.z)                uncompress "$target" ;;
      *)
        if command -v 7z >/dev/null 2>&1; then
          7z x -y "$target"
        elif command -v bsdtar >/dev/null 2>&1; then
          bsdtar -xf "$target"
        else
          echo "[ERROR] Unknown format for '$target'" >&2
          return 1
        fi
        ;;
    esac
    return $?
  }

  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo "[ERROR] '$file' is not a valid file" >&2
      failed=$((failed + 1))
      continue
    fi

    local dir="${file:h}"
    local base="${file:t}"
    local dir_prefix=""
    [[ "$dir" != "." ]] && dir_prefix="${dir}/"
    local can_dir="${dir:A}"

    local is_multipart=0
    local is_secondary=0
    local primary_file=""
    local multi_key=""

    if [[ "$base" == (#b)(#i)(*)\.part([0-9]##)\.(rar) ]]; then
      is_multipart=1
      local prefix="${match[1]}"
      local num="${match[2]}"
      local ext="${match[3]}"
      multi_key="${can_dir}/${prefix:l}:rar"
      local p_num=$(printf "%0*d" "${#num}" 1)
      primary_file="${dir_prefix}${prefix}.part${p_num}.${ext}"
      if [[ ! -f "$primary_file" && -f "${dir_prefix}${prefix}.part${p_num}.rar" ]]; then
        primary_file="${dir_prefix}${prefix}.part${p_num}.rar"
      fi
      if (( 10#$num > 1 )); then
        is_secondary=1
      fi
    elif [[ "$base" == (#b)(#i)(*)\.7z\.([0-9]##) ]]; then
      is_multipart=1
      local prefix="${match[1]}"
      local num="${match[2]}"
      multi_key="${can_dir}/${prefix:l}:7z"
      local p_num=$(printf "%0*d" "${#num}" 1)
      primary_file="${dir_prefix}${prefix}.7z.${p_num}"
      if (( 10#$num > 1 )); then
        is_secondary=1
      fi
    elif [[ "$base" == (#b)(#i)(*)\.r([0-9][0-9]) ]]; then
      is_multipart=1
      local prefix="${match[1]}"
      local num="${match[2]}"
      multi_key="${can_dir}/${prefix:l}:rar"
      if [[ -f "${dir_prefix}${prefix}.rar" ]]; then
        primary_file="${dir_prefix}${prefix}.rar"
        is_secondary=1
      elif [[ -f "${dir_prefix}${prefix}.r00" ]]; then
        primary_file="${dir_prefix}${prefix}.r00"
        if [[ "$num" != "00" ]]; then
          is_secondary=1
        fi
      else
        primary_file="${dir_prefix}${prefix}.rar"
        is_secondary=1
      fi
    elif [[ "$base" == (#b)(#i)(*)\.z([0-9][0-9]) ]]; then
      is_multipart=1
      local prefix="${match[1]}"
      multi_key="${can_dir}/${prefix:l}:zip"
      primary_file="${dir_prefix}${prefix}.zip"
      is_secondary=1
    fi

    if (( is_multipart )); then
      if [[ -n "${processed_primaries[$multi_key]}" ]]; then
        echo "[INFO] Skipping auxiliary multi-part volume '$file' (already extracted with primary volume)"
        success=$((success + 1))
        continue
      fi

      if (( is_secondary )); then
        if [[ -f "$primary_file" ]]; then
          echo "[INFO] '$file' is a multi-part volume. Extracting primary volume '$primary_file'..."
          if _extract_single "$primary_file"; then
            processed_primaries[$multi_key]=1
            success=$((success + 1))
          else
            echo "[ERROR] Failed to extract '$primary_file'" >&2
            failed=$((failed + 1))
          fi
          continue
        else
          echo "[ERROR] Cannot extract '$file': primary volume '$primary_file' not found" >&2
          failed=$((failed + 1))
          continue
        fi
      fi
    fi

    if _extract_single "$file"; then
      (( is_multipart )) && processed_primaries[$multi_key]=1
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
