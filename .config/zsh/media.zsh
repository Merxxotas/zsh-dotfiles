# =========================================================
# ~/.config/zsh/media.zsh - Universal Media Utilities
# Engines: ffmpeg & yt-dlp
# =========================================================

# 1. vconv: Convertidor universal de formatos de video (Soporta archivos individuales y lotes)
# Uso: vconv [-f] <archivo(s)> <formato_destino>
# Ejemplo: vconv video.webm mp4
# Ejemplo lote: vconv *.webm mp4
# Ejemplo rápido (stream copy sin re-render): vconv -f video.mkv mp4
vconv() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "[ERROR] ffmpeg is not installed."
    return 1
  fi

  local fast_copy=false
  if [[ "$1" == "-f" || "$1" == "--fast" ]]; then
    fast_copy=true
    shift
  fi

  if [ $# -lt 2 ]; then
    echo "Usage: vconv [-f] <input_file(s)> <target_extension>"
    echo "Examples:"
    echo "  vconv video.webm mp4"
    echo "  vconv *.webm mp4"
    echo "  vconv -f video.mkv mp4   (Fast stream copy without re-encoding)"
    return 1
  fi

  local target_ext="${@[-1]}"
  target_ext="${target_ext#.}"
  target_ext="${target_ext:l}"

  local input_files=("${@[1,-2]}")
  local success=0
  local failed=0

  for input in "${input_files[@]}"; do
    if [ ! -f "$input" ]; then
      echo "[ERROR] '$input' is not a valid file"
      failed=$((failed + 1))
      continue
    fi

    local base_name="${input%.*}"
    local output="${base_name}.${target_ext}"

    if [ "$input" = "$output" ]; then
      echo "[WARN] Source and destination are identical for '$input'. Skipping."
      continue
    fi

    echo "[INFO] Converting '$input' -> '$output'..."
    if [ "$fast_copy" = true ]; then
      ffmpeg -hide_banner -loglevel warning -stats -i "$input" -c copy "$output"
    else
      case "$target_ext" in
        mp4|mov)
          ffmpeg -hide_banner -loglevel warning -stats -i "$input" \
            -c:v libx264 -preset slow -crf 18 -pix_fmt yuv420p \
            -c:a aac -b:a 192k "$output"
          ;;
        webm)
          ffmpeg -hide_banner -loglevel warning -stats -i "$input" \
            -c:v libvpx-vp9 -crf 28 -b:v 0 \
            -c:a libopus -b:a 128k "$output"
          ;;
        mkv)
          ffmpeg -hide_banner -loglevel warning -stats -i "$input" \
            -c:v libx264 -preset slow -crf 18 \
            -c:a aac -b:a 192k "$output"
          ;;
        *)
          ffmpeg -hide_banner -loglevel warning -stats -i "$input" "$output"
          ;;
      esac
    fi

    if [ $? -eq 0 ]; then
      echo "[OK] Successfully converted to '$output'"
      success=$((success + 1))
    else
      echo "[ERROR] Failed to convert '$input'"
      failed=$((failed + 1))
    fi
  done

  echo "[INFO] Conversion complete: $success succeeded, $failed failed."
}

# 2. vdl: Descargador universal de video (YouTube, Twitter/X, TikTok, Instagram, Reddit, Twitch, etc.)
# Uso: vdl "<url>" [-q <resolution>] [-p] [-o <output_name>]
# Ejemplo: vdl "https://www.youtube.com/watch?v=..."
# Ejemplo: vdl "https://x.com/user/status/..."
vdl() {
  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "[ERROR] yt-dlp is not installed."
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: vdl <url> [options]"
    echo "Options:"
    echo "  -q, --quality <height>   Max vertical resolution (e.g. 1080, 720, 480)"
    echo "  -p, --playlist           Download entire playlist (disabled by default)"
    echo "  -o, --output <name>      Custom output filename template"
    echo "Examples:"
    echo "  vdl \"https://www.youtube.com/watch?v=...\""
    echo "  vdl \"https://x.com/user/status/...\""
    echo "  vdl \"https://www.youtube.com/watch?v=...\" -q 720"
    return 1
  fi

  local url="$1"
  shift

  local max_res=""
  local playlist_flag="--no-playlist"
  local custom_output="%(title)s.%(ext)s"

  while [ $# -gt 0 ]; do
    case "$1" in
      -q|--quality)
        max_res="$2"
        shift 2
        ;;
      -p|--playlist)
        playlist_flag="--yes-playlist"
        shift
        ;;
      -o|--output)
        custom_output="$2.%(ext)s"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  local format_selector="bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b"
  if [ -n "$max_res" ]; then
    format_selector="bv*[height<=${max_res}][ext=mp4]+ba[ext=m4a]/b[height<=${max_res}][ext=mp4] / bv*[height<=${max_res}]+ba/b[height<=${max_res}]"
  fi

  echo "[INFO] Downloading video from '$url'..."
  yt-dlp \
    -f "$format_selector" \
    --merge-output-format mp4 \
    --concurrent-fragments 5 \
    --embed-thumbnail \
    --embed-metadata \
    --windows-filenames \
    $playlist_flag \
    -o "$custom_output" \
    "$url"

  if [ $? -eq 0 ]; then
    echo "[OK] Download completed successfully."
  else
    echo "[ERROR] Download failed."
    return 1
  fi
}

# 3. adl: Descargador universal de audio (MP3 en alta calidad 320kbps con carátula)
# Uso: adl "<url>"
# Ejemplo: adl "https://www.youtube.com/watch?v=..."
adl() {
  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "[ERROR] yt-dlp is not installed."
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: adl <url>"
    echo "Example: adl \"https://www.youtube.com/watch?v=...\""
    return 1
  fi

  local url="$1"
  echo "[INFO] Downloading audio in 320kbps MP3 from '$url'..."
  yt-dlp \
    -x \
    --audio-format mp3 \
    --audio-quality 0 \
    --embed-thumbnail \
    --embed-metadata \
    --no-playlist \
    -o "%(title)s.%(ext)s" \
    "$url"

  if [ $? -eq 0 ]; then
    echo "[OK] Audio download completed successfully."
  else
    echo "[ERROR] Audio download failed."
    return 1
  fi
}

# 4. vaudio: Extrae la pista de audio de un video local a MP3
# Uso: vaudio <video_file(s)>
# Ejemplo: vaudio video.mp4
# Ejemplo: vaudio *.webm
vaudio() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "[ERROR] ffmpeg is not installed."
    return 1
  fi

  if [ $# -eq 0 ]; then
    echo "Usage: vaudio <video_file(s)>"
    echo "Example: vaudio video.mp4"
    echo "Example: vaudio *.webm"
    return 1
  fi

  for file in "$@"; do
    if [ ! -f "$file" ]; then
      echo "[ERROR] '$file' is not a valid file"
      continue
    fi

    local output="${file%.*}.mp3"
    echo "[INFO] Extracting audio from '$file' -> '$output'..."
    ffmpeg -hide_banner -loglevel warning -stats -i "$file" -vn -c:a libmp3lame -q:a 0 "$output"
    if [ $? -eq 0 ]; then
      echo "[OK] Audio extracted: '$output'"
    else
      echo "[ERROR] Failed to extract audio from '$file'"
    fi
  done
}

# 5. vcut: Recorte instantáneo de video sin pérdida de calidad (-c copy)
# Uso: vcut <video_file> <start_time> <end_time> [output_file]
# Ejemplo: vcut video.mp4 00:01:30 00:02:45 clip.mp4
vcut() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "[ERROR] ffmpeg is not installed."
    return 1
  fi

  if [ $# -lt 3 ]; then
    echo "Usage: vcut <input_video> <start_time> <end_time> [output_video]"
    echo "Time format: HH:MM:SS or MM:SS or seconds (e.g. 00:01:30 or 90)"
    echo "Example: vcut video.mp4 00:01:30 00:02:45 clip.mp4"
    return 1
  fi

  local input="$1"
  local start="$2"
  local end="$3"
  local output="${4:-${input%.*}_cut.${input##*.}}"

  if [ ! -f "$input" ]; then
    echo "[ERROR] '$input' is not a valid file"
    return 1
  fi

  echo "[INFO] Cutting '$input' from $start to $end -> '$output'..."
  ffmpeg -hide_banner -loglevel warning -stats -ss "$start" -to "$end" -i "$input" -c copy "$output"
  if [ $? -eq 0 ]; then
    echo "[OK] Trimmed video saved: '$output'"
  else
    echo "[ERROR] Failed to trim video."
    return 1
  fi
}

# 6. vgif: Creador de GIFs de alta calidad con algoritmo de dos pasadas (palettegen)
# Uso: vgif <input_video> [output.gif] [fps] [width]
# Ejemplo: vgif video.mp4
# Ejemplo: vgif video.mp4 animacion.gif 15 480
vgif() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "[ERROR] ffmpeg is not installed."
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: vgif <input_video> [output.gif] [fps=15] [width=480]"
    echo "Example: vgif video.mp4"
    echo "Example: vgif video.mp4 animacion.gif 20 640"
    return 1
  fi

  local input="$1"
  local output="${2:-${input%.*}.gif}"
  local fps="${3:-15}"
  local width="${4:-480}"

  if [ ! -f "$input" ]; then
    echo "[ERROR] '$input' is not a valid file"
    return 1
  fi

  local palette="/tmp/palette_$(date +%s%N).png"
  echo "[INFO] Generating high-quality GIF from '$input' (${fps}fps, width ${width}px)..."

  ffmpeg -hide_banner -loglevel warning -i "$input" -vf "fps=${fps},scale=${width}:-1:flags=lanczos,palettegen" -update 1 -y "$palette"
  ffmpeg -hide_banner -loglevel warning -stats -i "$input" -i "$palette" -filter_complex "fps=${fps},scale=${width}:-1:flags=lanczos[x];[x][1:v]paletteuse" -y "$output"
  
  rm -f "$palette"

  if [ $? -eq 0 ]; then
    echo "[OK] High quality GIF generated: '$output'"
  else
    echo "[ERROR] Failed to generate GIF."
    return 1
  fi
}
