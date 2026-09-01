# =========================================================
# ~/.config/zsh/media.zsh - Universal Media Utilities
# Engines: ffmpeg & yt-dlp + Smart Multi-Platform Resolvers
# =========================================================

# --- Internal Helper: Multi-Platform Fallback Resolver (Twitter/X, TikTok, Kick) ---
_vdl_fallback_resolve() {
  local target_url="$1"
  python3 -c "
import urllib.request, json, re, sys

url = sys.argv[1].strip()

# 1. Resolve Twitter/X (Long, Sensitive, NSFW or Amplify Videos)
if 'x.com' in url or 'twitter.com' in url:
    m = re.search(r'status/(\d+)', url)
    if m:
        tweet_id = m.group(1)
        for api_url in [f'https://api.fxtwitter.com/status/{tweet_id}', f'https://api.vxtwitter.com/status/{tweet_id}']:
            try:
                req = urllib.request.Request(api_url, headers={'User-Agent': 'Mozilla/5.0'})
                res = urllib.request.urlopen(req, timeout=10)
                data = json.loads(res.read().decode())
                media = data.get('tweet', {}).get('media', {}).get('videos', [])
                if media:
                    formats = media[0].get('formats', [])
                    mp4_formats = [f for f in formats if f.get('container') == 'mp4']
                    mp4_formats.sort(key=lambda x: x.get('bitrate', 0), reverse=True)
                    best = mp4_formats[0]['url'] if mp4_formats else media[0]['url']
                    title = data.get('tweet', {}).get('text', 'twitter_video')[:40]
                    title = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_')
                    print(f'RESOLVED|{best}|{title or \"twitter_video\"}')
                    sys.exit(0)
            except Exception:
                pass

# 2. Resolve TikTok (Anti-Bot Bypass & Clean No-Watermark MP4)
if 'tiktok.com' in url:
    try:
        req = urllib.request.Request(f'https://www.tikwm.com/api/?url={url}', headers={'User-Agent': 'Mozilla/5.0'})
        res = urllib.request.urlopen(req, timeout=10)
        data = json.loads(res.read().decode())
        if data.get('code') == 0:
            play_url = data['data']['play']
            title = data['data'].get('title', 'tiktok_video')[:40]
            title = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_')
            print(f'RESOLVED|{play_url}|{title or \"tiktok_video\"}')
            sys.exit(0)
    except Exception:
        pass

# 3. Resolve Kick.com (VODs & HLS Streams)
if 'kick.com' in url:
    m_vod = re.search(r'kick\.com/([^/?#]+)/videos/([a-zA-Z0-9-]+)', url)
    if m_vod:
        channel, uuid = m_vod.group(1), m_vod.group(2)
        try:
            req = urllib.request.Request(f'https://kick.com/api/v2/channels/{channel}/videos', headers={'User-Agent': 'Mozilla/5.0'})
            res = urllib.request.urlopen(req, timeout=10)
            data = json.loads(res.read().decode())
            videos = data if isinstance(data, list) else data.get('videos', [])
            for v in videos:
                if v.get('video', {}).get('uuid') == uuid or str(v.get('id')) == uuid:
                    source = v.get('source')
                    title = v.get('session_title', 'kick_vod')[:40]
                    title = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_')
                    print(f'RESOLVED|{source}|{title or \"kick_vod\"}')
                    sys.exit(0)
            print('KICK_EXPIRED')
            sys.exit(0)
        except Exception:
            pass

    m_single = re.search(r'kick\.com/video/([a-zA-Z0-9-]+)', url)
    if m_single:
        uuid = m_single.group(1)
        try:
            req = urllib.request.Request(f'https://kick.com/api/v1/video/{uuid}', headers={'User-Agent': 'Mozilla/5.0'})
            res = urllib.request.urlopen(req, timeout=10)
            data = json.loads(res.read().decode())
            source = data.get('source')
            if source:
                title = data.get('session_title', 'kick_vod')[:40]
                title = re.sub(r'[^\w\s-]', '', title).strip().replace(' ', '_')
                print(f'RESOLVED|{source}|{title or \"kick_vod\"}')
                sys.exit(0)
        except Exception:
            pass

print('NOT_RESOLVED')
" "$target_url" 2>/dev/null || echo "NOT_RESOLVED"
}

# 1. vconv: Universal Video Format Transcoder (Single & Batch File Processing)
# Usage: vconv [-f] <input_file(s)> <target_extension>
# Examples:
#   vconv video.webm mp4
#   vconv *.webm mp4
#   vconv -f video.mkv mp4   (Fast stream copy without re-encoding)
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

# 2. vdl: Universal Video Downloader (YouTube, Twitter/X, TikTok, Instagram, Reddit, Twitch, Kick, Vimeo, etc.)
# Supported Formats: mp4, mkv, webm, mov, avi
# Supported Codecs: av1, h264, vp9, hevc
# Usage: vdl "<url>" [-f <format>] [-q <resolution>] [-c <codec>] [-p] [-o <output_name>]
vdl() {
  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo "[ERROR] yt-dlp is not installed."
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: vdl <url> [options]"
    echo "Options:"
    echo "  -f, --format <ext>       Target format container (mp4, mkv, webm, mov, avi) [default: mp4]"
    echo "  -q, --quality <height>   Max vertical resolution (e.g. 2160, 1440, 1080, 720, 480)"
    echo "  -c, --codec <codec>      Preferred video codec (av1, h264, vp9, hevc)"
    echo "  -p, --playlist           Download entire playlist (disabled by default)"
    echo "  -o, --output <name>      Custom output filename template"
    echo "Examples:"
    echo "  vdl \"https://www.youtube.com/watch?v=...\""
    echo "  vdl \"https://www.youtube.com/watch?v=...\" -f mkv"
    echo "  vdl \"https://x.com/user/status/...\" -f mp4"
    echo "  vdl \"https://www.tiktok.com/@user/video/...\""
    echo "  vdl \"https://kick.com/channel/videos/...\""
    return 1
  fi

  local raw_url="$1"
  shift

  # Pre-sanitize URL
  local clean_url="$raw_url"
  if [[ "$raw_url" =~ (x\.com|twitter\.com) ]]; then
    clean_url=$(echo "$raw_url" | sed -E 's#/video/[0-9]+##g; s#\?.*##g')
  fi

  local target_format="mp4"
  local max_res=""
  local preferred_codec=""
  local playlist_flag="--no-playlist"
  local user_custom_output=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -f|--format)
        target_format="${2#.}"
        target_format="${target_format:l}"
        shift 2
        ;;
      -q|--quality)
        max_res="$2"
        shift 2
        ;;
      -c|--codec)
        preferred_codec="${2:l}"
        shift 2
        ;;
      -p|--playlist)
        playlist_flag="--yes-playlist"
        shift
        ;;
      -o|--output)
        user_custom_output="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done

  local custom_output="%(title)s.%(ext)s"
  if [ -n "$user_custom_output" ]; then
    custom_output="${user_custom_output}.%(ext)s"
  fi

  # Build Intelligent Format Selector
  local vcodec_filter=""
  case "$preferred_codec" in
    av1|av01)
      vcodec_filter="[vcodec^=av01]"
      ;;
    h264|avc|avc1)
      vcodec_filter="[vcodec^=avc|vcodec^=h264]"
      ;;
    vp9|vp09)
      vcodec_filter="[vcodec^=vp09|vcodec^=vp9]"
      ;;
    hevc|h265|hev1|hvc1)
      vcodec_filter="[vcodec^=hev|vcodec^=hvc|vcodec^=h265]"
      ;;
  esac

  local res_filter=""
  if [ -n "$max_res" ]; then
    res_filter="[height<=${max_res}]"
  fi

  local format_selector=""
  if [ -n "$vcodec_filter" ] || [ -n "$res_filter" ]; then
    format_selector="bv*${vcodec_filter}${res_filter}+ba/b${vcodec_filter}${res_filter}/bv*${res_filter}+ba/b"
  else
    if [ "$target_format" = "webm" ]; then
      format_selector="bv*[ext=webm]+ba[ext=webm]/bv*+ba/b"
    else
      format_selector="bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4] / bv*+ba/b"
    fi
  fi

  local thumbnail_flag="--embed-thumbnail"
  if [ "$target_format" = "webm" ]; then
    thumbnail_flag=""
  fi

  echo "[INFO] Downloading video in '$target_format' format from '$clean_url'..."
  if yt-dlp \
    -f "$format_selector" \
    --merge-output-format "$target_format" \
    --concurrent-fragments 5 \
    $thumbnail_flag \
    --embed-metadata \
    --windows-filenames \
    $playlist_flag \
    -o "$custom_output" \
    "$clean_url" 2>/dev/null; then
      echo "[OK] Download completed successfully in '$target_format' format."
      return 0
  fi

  # --- Automatic Contingency Engine (Smart Fallback) ---
  echo "[INFO] Direct scraping failed. Activating multi-platform smart fallback..."
  local fallback_result="$(_vdl_fallback_resolve "$raw_url")"

  if [[ "$fallback_result" == "KICK_EXPIRED" ]]; then
    echo "[ERROR] This Kick VOD is no longer available on Kick's servers (expired or deleted by streamer)."
    return 1
  elif [[ "$fallback_result" =~ ^RESOLVED\| ]]; then
    local stream_url=$(echo "$fallback_result" | cut -d'|' -f2)
    local stream_title=$(echo "$fallback_result" | cut -d'|' -f3)
    
    local out_filename="${user_custom_output:-$stream_title}.${target_format}"
    echo "[INFO] Stream resolved. Downloading high quality stream to '$out_filename'..."

    if yt-dlp \
      --merge-output-format "$target_format" \
      --concurrent-fragments 5 \
      -o "$out_filename" \
      "$stream_url"; then
        echo "[OK] Download completed successfully via smart fallback: '$out_filename'"
        return 0
    elif command -v ffmpeg >/dev/null 2>&1; then
        ffmpeg -hide_banner -loglevel warning -stats -i "$stream_url" -c copy "$out_filename"
        if [ $? -eq 0 ]; then
          echo "[OK] Download completed successfully via ffmpeg stream copy: '$out_filename'"
          return 0
        fi
    fi
  fi

  echo "[ERROR] All download attempts and fallbacks failed for '$raw_url'."
  return 1
}

# 3. adl: Universal Audio Downloader (320kbps MP3 with Embedded Artwork & Metadata)
# Usage: adl "<url>"
# Example: adl "https://www.youtube.com/watch?v=..."
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

# 4. vaudio: Local Video Audio Extractor (Outputs MP3)
# Usage: vaudio <video_file(s)>
# Examples:
#   vaudio video.mp4
#   vaudio *.webm
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

# 5. vcut: Instant Lossless Video Trimmer (-c copy)
# Usage: vcut <input_video> <start_time> <end_time> [output_video]
# Time Format: HH:MM:SS or MM:SS or seconds (e.g. 00:01:30 or 90)
# Example: vcut video.mp4 00:01:30 00:02:45 clip.mp4
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

# 6. vgif: High-Quality Animated GIF Generator (2-Pass Optimized Palette)
# Usage: vgif <input_video> [output.gif] [fps] [width]
# Examples:
#   vgif video.mp4
#   vgif video.mp4 animation.gif 15 480
vgif() {
  if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "[ERROR] ffmpeg is not installed."
    return 1
  fi

  if [ -z "$1" ]; then
    echo "Usage: vgif <input_video> [output.gif] [fps=15] [width=480]"
    echo "Example: vgif video.mp4"
    echo "Example: vgif video.mp4 animation.gif 20 640"
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
