# 04 - Multimedia Suite (`media.zsh`)

The suite embeds robust, production-grade CLI tools for processing video, audio, and animations using `ffmpeg` and `yt-dlp`.

---

## Commands Reference

### 1. `vconv` - Universal Video Transcoder & Batch Converter
Converts single or multiple videos between formats (`mp4`, `mkv`, `webm`, `avi`, `mov`, `ts`, `wmv`) with automatic hardware acceleration (GPU) and intelligent CPU fallback.

```bash
# Convert a single video to high-quality MP4 using GPU hardware acceleration (5x-20x faster)
vconv recording.webm mp4

# Batch convert all WebM files in current directory
vconv *.webm mp4

# Fast container switch without re-encoding (-f for stream copy, 0% quality loss)
vconv -f source.mkv mp4

# Force CPU encoding (shows warning if video > 3 minutes)
vconv --cpu recording.webm mp4

# Mathematically lossless encoding (-crf 0)
vconv --lossless archive.mkv mp4

# Convert to legacy formats (e.g. AVI with MPEG-4/XviD + MP3 for old DVD/car players)
vconv clip.mp4 avi
```

#### Hardware Acceleration & Fallback Matrix

`vconv` dynamically probes available hardware encoders without adding startup latency:

| Engine | Hardware Support | Encoder | Flags / Presets |
| :--- | :--- | :--- | :--- |
| **VideoToolbox** | Apple Silicon (M1–M4) & macOS | `h264_videotoolbox` | `-q:v 60 -pix_fmt yuv420p` |
| **NVENC** | NVIDIA GeForce / RTX / Quadro | `h264_nvenc` | `-preset p5 -cq 20 -pix_fmt yuv420p` |
| **VA-API** | AMD Radeon & Intel on Linux (`/dev/dri/renderD*`) | `h264_vaapi` | `-vf format=nv12,hwupload -qp 20` |
| **QSV** | Intel QuickSync Video | `h264_qsv` | `-global_quality 20 -pix_fmt yuv420p` |
| **CPU Fallback** | Universal software fallback | `libx264` / `libvpx-vp9` | `-crf 18 -preset slow` (Visually lossless) |

- **Automatic Fallback:** If GPU encoding fails during execution (unsupported profile, VRAM limits), `vconv` automatically retries with CPU (`libx264`).
- **CPU Warning Threshold:** When encoding via CPU, `vconv` measures video duration via `ffprobe` and displays a warning only if the video exceeds 3 minutes (180s).

### 2. `vdl` - Universal Video Downloader
Downloads videos with metadata and thumbnail integration from YouTube, Twitter/X, TikTok, Instagram, Reddit, and Twitch.

```bash
# Basic video download
vdl "https://www.youtube.com/watch?v=VIDEO_ID"

# Enforce maximum resolution limits (e.g. 720p or 1080p)
vdl "https://www.youtube.com/watch?v=VIDEO_ID" -q 720
vdl "https://www.youtube.com/watch?v=VIDEO_ID" -q 1080

# Download full playlist
vdl "https://www.youtube.com/playlist?list=PLAYLIST_ID" -p
```

### 3. `adl` - Audio Downloader
Extracts and downloads audio into high-fidelity 320kbps MP3 with embedded artwork and ID3 tags.

```bash
adl "https://www.youtube.com/watch?v=VIDEO_ID"
```

### 4. `vaudio` - Local Video-to-Audio Extractor
Extracts audio from locally stored video files:

```bash
vaudio podcast.mp4
vaudio *.mov
```

### 5. `vcut` - Lossless Video Trimming
Trims video clips between start and end timestamps using lossless stream copying (`-c copy`):

```bash
# Syntax: vcut <input> <start_time> <end_time> [output]
vcut gameplay.mp4 00:01:15 00:02:30 highlight.mp4
```

### 6. `vgif` - High-Quality Animated GIF Generator
Uses two-pass palette generation (`palettegen` / `paletteuse`) for crisp, artifact-free GIFs:

```bash
# Syntax: vgif <input> [output] [fps=15] [width=480]
vgif demo.mp4 demo.gif 20 640
```
