#!/usr/bin/env bash
# ==============================================================================
#  ZSH Dotfiles - Production Universal Installer
#  Architecture: XDG-compliant, transactional staging, deterministic security
#  Repository: https://github.com/Merxxotas/zsh-dotfiles
# ==============================================================================

set -eo pipefail

# --- Colors & Output Formatting ---
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Resolve Canonical Script Directory ---
resolve_script_dir() {
  local src="${BASH_SOURCE[0]}"
  while [ -L "$src" ]; do
    local dir
    dir="$(cd -P "$(dirname "$src")" && pwd)"
    src="$(readlink "$src")"
    [[ "$src" != /* ]] && src="$dir/$src"
  done
  cd -P "$(dirname "$src")" && pwd
}
SCRIPT_DIR="$(resolve_script_dir)"

# --- Sudo wrapper for containers / root ---
run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif command -v sudo >/dev/null 2>&1; then
    sudo "$@"
  else
    "$@"
  fi
}

# --- Default Parameters ---
INSTALL_MODE="copy"
UNATTENDED=false
SKIP_DEPS=false
DRY_RUN=false
SYNC_ROOT=false
CHANGE_SHELL=true
INSTALL_PLUGINS=false
RESTORE_BACKUP_ID=""
LIST_BACKUPS=false

# --- Argument Parsing ---
parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --mode)
        [ $# -ge 2 ] || { echo -e "${RED}[ERROR] Missing value for --mode${NC}" >&2; exit 2; }
        case "$2" in
          copy|symlink) INSTALL_MODE="$2" ;;
          *) echo -e "${RED}[ERROR] Invalid mode '$2'. Allowed: copy, symlink${NC}" >&2; exit 2 ;;
        esac
        shift 2
        ;;
      -s|--symlink)
        INSTALL_MODE="symlink"
        shift
        ;;
      -y|--yes|--unattended|--non-interactive)
        UNATTENDED=true
        shift
        ;;
      --no-deps|--skip-deps)
        SKIP_DEPS=true
        shift
        ;;
      --dry-run)
        DRY_RUN=true
        shift
        ;;
      --sync-root)
        SYNC_ROOT=true
        shift
        ;;
      --no-change-shell)
        CHANGE_SHELL=false
        shift
        ;;
      --install-plugins)
        INSTALL_PLUGINS=true
        shift
        ;;
      --list-backups)
        LIST_BACKUPS=true
        shift
        ;;
      --restore)
        [ $# -ge 2 ] || { echo -e "${RED}[ERROR] Missing backup ID for --restore${NC}" >&2; exit 2; }
        RESTORE_BACKUP_ID="$2"
        shift 2
        ;;
      -h|--help)
        echo "Usage: ./install.sh [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --mode <copy|symlink>    Installation mode (default: copy)"
        echo "  -s, --symlink            Shortcut for --mode symlink"
        echo "  -y, --yes, --unattended  Execute non-interactively without confirmation prompts"
        echo "  --no-deps, --skip-deps   Skip dependency downloads and package installation"
        echo "  --dry-run                Print installation plan without making changes"
        echo "  --sync-root              Synchronize configuration to root with Tokyo theme"
        echo "  --no-change-shell        Do not prompt to change default login shell"
        echo "  --install-plugins        Install pinned plugins from plugins.lock"
        echo "  --list-backups           List available configuration backups"
        echo "  --restore <backup_id>    Restore a specific configuration backup"
        echo "  -h, --help               Show this help message"
        exit 0
        ;;
      *)
        echo -e "${RED}[ERROR] Unknown option: $1${NC}" >&2
        echo "Run './install.sh --help' for usage details." >&2
        exit 2
        ;;
    esac
  done
}

# --- Resolve Target Paths ---
resolve_paths() {
  TARGET_HOME="${HOME:?HOME environment variable is required}"
  
  if [ -n "${XDG_CONFIG_HOME:-}" ]; then
    TARGET_CONFIG_HOME="$XDG_CONFIG_HOME"
  else
    TARGET_CONFIG_HOME="$TARGET_HOME/.config"
  fi

  if [ -n "${XDG_CACHE_HOME:-}" ]; then
    TARGET_CACHE_HOME="$XDG_CACHE_HOME"
  else
    TARGET_CACHE_HOME="$TARGET_HOME/.cache"
  fi

  if [ -n "${XDG_DATA_HOME:-}" ]; then
    TARGET_DATA_HOME="$XDG_DATA_HOME"
  else
    TARGET_DATA_HOME="$TARGET_HOME/.local/share"
  fi

  if [ -n "${XDG_STATE_HOME:-}" ]; then
    TARGET_STATE_HOME="$XDG_STATE_HOME"
  else
    TARGET_STATE_HOME="$TARGET_HOME/.local/state"
  fi

  TARGET_ZDOTDIR="$TARGET_CONFIG_HOME/zsh"
  TARGET_ZSHENV="$TARGET_HOME/.zshenv"
  BACKUP_DIR="$TARGET_STATE_HOME/zsh/backups"
}

# --- OS Detection ---
detect_platform() {
  OS="unknown"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  elif [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    OS="${ID:-linux}"
  fi
}

# --- Backup Management ---
list_backups() {
  resolve_paths
  if [ ! -d "$BACKUP_DIR" ]; then
    echo "No backups found in $BACKUP_DIR"
    return 0
  fi
  echo -e "${BLUE}${BOLD}Available Backups:${NC}"
  for b in "$BACKUP_DIR"/*; do
    if [ -d "$b" ]; then
      local bid
      bid="$(basename "$b")"
      local btime=""
      [ -f "$b/timestamp" ] && btime="$(cat "$b/timestamp")"
      echo -e "  - ${CYAN}${bid}${NC} (${btime:-unknown date})"
    fi
  done
}

restore_backup() {
  local bid="$1"
  resolve_paths
  local target_backup="$BACKUP_DIR/$bid"
  if [ ! -d "$target_backup" ]; then
    echo -e "${RED}[ERROR] Backup '$bid' not found in $BACKUP_DIR${NC}" >&2
    return 1
  fi

  echo -e "${BLUE}[INFO] Restoring backup '$bid'...${NC}"
  if [ -f "$target_backup/manifest.tsv" ]; then
    while IFS=$'\t' read -r rel_path file_type link_target; do
      [[ "$rel_path" =~ ^#.*$ || -z "$rel_path" ]] && continue
      local dest=""
      if [ "$rel_path" = ".zshenv" ]; then
        dest="$TARGET_ZSHENV"
      else
        dest="$TARGET_CONFIG_HOME/$rel_path"
      fi

      rm -rf "$dest"
      if [ "$file_type" = "symlink" ]; then
        ln -sf "$link_target" "$dest"
      elif [ -e "$target_backup/data/$rel_path" ]; then
        mkdir -p "$(dirname "$dest")"
        cp -r "$target_backup/data/$rel_path" "$dest"
      fi
    done < "$target_backup/manifest.tsv"
    echo -e "${GREEN}[OK] Backup restored successfully.${NC}"
  else
    echo -e "${RED}[ERROR] Backup manifest is missing.${NC}" >&2
    return 1
  fi
}

# --- Classify Path ---
classify_path() {
  local path="$1"
  if [ ! -e "$path" ] && [ ! -L "$path" ]; then
    echo "absent"
  elif [ -L "$path" ]; then
    local target
    target="$(readlink "$path" || echo "")"
    if [ "$target" = "$SCRIPT_DIR" ] || [ "$target" = "$SCRIPT_DIR/.config/zsh" ] || [ "$target" = "$SCRIPT_DIR/.zshenv" ]; then
      echo "symlink_to_repo"
    elif [ -e "$path" ]; then
      echo "symlink_external_valid"
    else
      echo "symlink_broken"
    fi
  elif [ -f "$path" ]; then
    echo "regular_file"
  elif [ -d "$path" ]; then
    echo "directory"
  else
    echo "unexpected_type"
  fi
}

# --- Create Transactional Backup ---
create_backup() {
  local zdotdir_status
  zdotdir_status="$(classify_path "$TARGET_ZDOTDIR")"
  local zshenv_status
  zshenv_status="$(classify_path "$TARGET_ZSHENV")"

  if [ "$zdotdir_status" = "absent" ] && [ "$zshenv_status" = "absent" ]; then
    return 0
  fi
  if [ "$zdotdir_status" = "symlink_to_repo" ] && [ "$zshenv_status" = "symlink_to_repo" ]; then
    return 0
  fi

  local ts
  ts="$(date +%Y%m%dT%H%M%S)"
  local rand_id
  rand_id="$(head -c 4 /dev/urandom 2>/dev/null | xxd -p 2>/dev/null || echo "$$")"
  local snap_dir="$BACKUP_DIR/${ts}-${rand_id}"

  mkdir -p "$snap_dir/data"
  echo "$ts" > "$snap_dir/timestamp"

  echo -e "  ${YELLOW}[BACKUP]${NC} Backing up existing configuration to ${CYAN}${ts}-${rand_id}${NC}..."
  {
    echo "#manifest_version:1"
    echo "#path	type	link_target"

    if [ "$zshenv_status" = "symlink_external_valid" ] || [ "$zshenv_status" = "symlink_broken" ]; then
      echo ".zshenv	symlink	$(readlink "$TARGET_ZSHENV")"
    elif [ "$zshenv_status" = "regular_file" ]; then
      cp "$TARGET_ZSHENV" "$snap_dir/data/.zshenv"
      echo ".zshenv	file	-"
    fi

    if [ "$zdotdir_status" = "symlink_external_valid" ] || [ "$zdotdir_status" = "symlink_broken" ]; then
      echo "zsh	symlink	$(readlink "$TARGET_ZDOTDIR")"
    elif [ "$zdotdir_status" = "directory" ]; then
      mkdir -p "$snap_dir/data/zsh"
      cp -r "$TARGET_ZDOTDIR/"* "$snap_dir/data/zsh/" 2>/dev/null || true
      [ -f "$TARGET_ZDOTDIR/.zshrc" ] && cp "$TARGET_ZDOTDIR/.zshrc" "$snap_dir/data/zsh/.zshrc"
      [ -f "$TARGET_ZDOTDIR/.zshenv" ] && cp "$TARGET_ZDOTDIR/.zshenv" "$snap_dir/data/zsh/.zshenv"
      echo "zsh	directory	-"
    fi
  } > "$snap_dir/manifest.tsv"

  echo -e "  ${GREEN}[OK]${NC} Snapshot stored at $snap_dir"
}

# --- Verified Dependency Installer via dependencies.lock ---
install_locked_dependency() {
  local name="$1"
  local target_os="$2"
  local target_arch="$3"
  local lockfile="$SCRIPT_DIR/dependencies.lock"

  [ -f "$lockfile" ] || return 1

  local matched_url=""
  local matched_sha=""
  local matched_ver=""

  while IFS=$'\t' read -r dname dver dos darch durl dsha; do
    [[ "$dname" =~ ^#.*$ || -z "$dname" ]] && continue
    if [ "$dname" = "$name" ] && { [ "$dos" = "$target_os" ] || [ "$dos" = "all" ]; } && { [ "$darch" = "$target_arch" ] || [ "$darch" = "all" ]; }; then
      matched_url="$durl"
      matched_sha="$dsha"
      matched_ver="$dver"
      break
    fi
  done < "$lockfile"

  if [ -z "$matched_url" ]; then
    return 1
  fi

  echo -e "  [INFO] Downloading verified $name $matched_ver ($target_arch)..."
  local tmp_dir
  tmp_dir="$(mktemp -d)"
  local tmp_file="$tmp_dir/$name"

  if ! curl -sL --proto '=https' --tlsv1.2 "$matched_url" -o "$tmp_file"; then
    echo -e "  ${RED}[ERROR] Failed to download $name from $matched_url${NC}" >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  # Compute checksum
  local computed_sha=""
  if command -v sha256sum >/dev/null 2>&1; then
    computed_sha="$(sha256sum "$tmp_file" | awk '{print $1}')"
  elif command -v shasum >/dev/null 2>&1; then
    computed_sha="$(shasum -a 256 "$tmp_file" | awk '{print $1}')"
  fi

  if [ -n "$computed_sha" ] && [ "$computed_sha" != "$matched_sha" ]; then
    echo -e "  ${RED}[ERROR] Checksum mismatch for $name! Expected $matched_sha, got $computed_sha${NC}" >&2
    rm -rf "$tmp_dir"
    return 1
  fi

  # Handle tarball or raw binary
  mkdir -p "$TARGET_HOME/.local/bin"
  if [[ "$matched_url" == *.tar.gz ]]; then
    tar -xzf "$tmp_file" -C "$tmp_dir" 2>/dev/null || true
    if [ -f "$tmp_dir/$name" ]; then
      cp "$tmp_dir/$name" "$TARGET_HOME/.local/bin/$name"
    elif [ -f "$tmp_dir/bin/$name" ]; then
      cp "$tmp_dir/bin/$name" "$TARGET_HOME/.local/bin/$name"
    fi
  else
    cp "$tmp_file" "$TARGET_HOME/.local/bin/$name"
  fi

  chmod 755 "$TARGET_HOME/.local/bin/$name"
  if [ "$(id -u)" -eq 0 ] || [ -w "/usr/local/bin" ]; then
    mkdir -p "/usr/local/bin" 2>/dev/null || true
    ln -sf "$TARGET_HOME/.local/bin/$name" "/usr/local/bin/$name" 2>/dev/null || true
  fi
  rm -rf "$tmp_dir"
  echo -e "  ${GREEN}[OK]${NC} Installed $name into $TARGET_HOME/.local/bin/$name"
  return 0
}

# --- System Package Installer ---
install_packages() {
  echo -e "\n${BLUE}${BOLD}[INFO] Installing system dependencies...${NC}"
  case "$OS" in
    ubuntu|debian|pop|linuxmint)
      run_sudo apt-get update -y
      run_sudo apt-get install -y zsh fzf bat fd-find curl git jq neovim unzip tar ffmpeg yt-dlp || true
      mkdir -p "$TARGET_HOME/.local/bin"
      if command -v batcat >/dev/null 2>&1; then
        ln -sf "$(command -v batcat)" "$TARGET_HOME/.local/bin/bat" || true
      fi
      if command -v fdfind >/dev/null 2>&1; then
        ln -sf "$(command -v fdfind)" "$TARGET_HOME/.local/bin/fd" || true
      fi
      ;;
    arch|cachyos|manjaro|endeavouros)
      run_sudo pacman -S --needed --noconfirm zsh fzf bat eza fd curl git neovim jq atuin unzip tar ffmpeg yt-dlp || true
      ;;
    fedora|rhel|centos|rocky|almalinux)
      run_sudo dnf install -y --allowerasing zsh fzf bat eza fd-find curl git neovim jq atuin unzip tar ffmpeg yt-dlp || true
      if command -v fdfind >/dev/null 2>&1; then
        run_sudo ln -sf "$(command -v fdfind)" "/usr/local/bin/fd" 2>/dev/null || true
      fi
      ;;
    opensuse*|suse)
      run_sudo zypper --non-interactive install -y zsh fzf bat eza fd curl git neovim jq atuin unzip tar ffmpeg yt-dlp || true
      ;;
    alpine)
      run_sudo apk update || true
      run_sudo apk add zsh fzf bat eza fd curl git neovim jq unzip tar shadow ffmpeg yt-dlp || true
      ;;
    macos)
      if command -v brew >/dev/null 2>&1; then
        brew install zsh fzf bat eza fd curl git neovim jq atuin ffmpeg yt-dlp || true
      fi
      ;;
    *)
      echo -e "${YELLOW}[WARN] Generic environment. Verifying present binaries...${NC}"
      ;;
  esac

  # Architecture detection for standalone fallbacks
  local uname_arch
  uname_arch="$(uname -m)"
  local arch="x86_64"
  [[ "$uname_arch" == "aarch64" || "$uname_arch" == "arm64" ]] && arch="aarch64"

  local os_type="linux"
  [[ "$OS" == "macos" ]] && os_type="macos"

  # Standalone verified fallbacks
  if ! command -v yt-dlp >/dev/null 2>&1; then
    install_locked_dependency "yt-dlp" "$os_type" "$arch" || true
  fi
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    install_locked_dependency "oh-my-posh" "$os_type" "$arch" || true
  fi
  if ! command -v atuin >/dev/null 2>&1; then
    install_locked_dependency "atuin" "$os_type" "$arch" || true
  fi
}

# --- Deploy Configuration (Transactional & File-based) ---
deploy_configuration() {
  echo -e "\n${BLUE}${BOLD}[INFO] Deploying configuration (Mode: $INSTALL_MODE)...${NC}"

  # Base directory initialization
  mkdir -p "$TARGET_ZDOTDIR/themes" \
           "$TARGET_STATE_HOME/zsh" \
           "$TARGET_CACHE_HOME/oh-my-posh/themes" \
           "$TARGET_DATA_HOME/zsh/plugins" \
           "$TARGET_HOME/.local/bin"

  # Migrate legacy directory symlink if present
  if [ -L "$TARGET_ZDOTDIR" ]; then
    echo -e "  ${INFO}[INFO] Migrating legacy directory symlink to file-based model...${NC}"
    rm -f "$TARGET_ZDOTDIR"
    mkdir -p "$TARGET_ZDOTDIR/themes"
  fi

  local managed_modules=(
    ".zshenv"
    ".zshrc"
    "aliases.zsh"
    "bindings.zsh"
    "dev-env.zsh"
    "fzf.zsh"
    "fzf-tab.zsh"
    "helpers.zsh"
    "media.zsh"
    "plugins.zsh"
    "prompt.zsh"
  )

  if [ "$INSTALL_MODE" = "symlink" ]; then
    # 1. Symlink ~/.zshenv
    ln -sf "$SCRIPT_DIR/.zshenv" "$TARGET_ZSHENV"

    # 2. Symlink each managed module
    for mod in "${managed_modules[@]}"; do
      ln -sf "$SCRIPT_DIR/.config/zsh/$mod" "$TARGET_ZDOTDIR/$mod"
    done

    # 3. Symlink built-in themes
    for theme in "$SCRIPT_DIR/.config/zsh/themes"/*.omp.json; do
      if [ -f "$theme" ]; then
        ln -sf "$theme" "$TARGET_ZDOTDIR/themes/$(basename "$theme")"
      fi
    done
  else
    # Copy Mode with staging
    local stage_dir
    stage_dir="$(mktemp -d -t zsh_stage.XXXXXX)"

    # Stage files
    cp "$SCRIPT_DIR/.zshenv" "$stage_dir/.zshenv"
    mkdir -p "$stage_dir/zsh/themes"
    for mod in "${managed_modules[@]}"; do
      cp "$SCRIPT_DIR/.config/zsh/$mod" "$stage_dir/zsh/$mod"
    done
    cp "$SCRIPT_DIR/.config/zsh/themes"/*.omp.json "$stage_dir/zsh/themes/" 2>/dev/null || true

    # Validate syntax in staging
    if command -v zsh >/dev/null 2>&1; then
      for f in "$stage_dir/zsh"/*.zsh "$stage_dir/zsh/.zshrc" "$stage_dir/zsh/.zshenv" "$stage_dir/.zshenv"; do
        [ -f "$f" ] && zsh -n "$f"
      done
    fi

    # If any target is a symlink, remove the symlink first so cp creates a regular file
    [ -L "$TARGET_ZSHENV" ] && rm -f "$TARGET_ZSHENV"
    for mod in "${managed_modules[@]}"; do
      [ -L "$TARGET_ZDOTDIR/$mod" ] && rm -f "$TARGET_ZDOTDIR/$mod"
    done
    for theme in "$TARGET_ZDOTDIR/themes"/*.omp.json; do
      [ -L "$theme" ] && rm -f "$theme"
    done

    # Activate
    cp "$stage_dir/.zshenv" "$TARGET_ZSHENV"
    cp -r "$stage_dir/zsh/"* "$TARGET_ZDOTDIR/"
    cp "$stage_dir/zsh/.zshenv" "$TARGET_ZDOTDIR/.zshenv"
    cp "$stage_dir/zsh/.zshrc" "$TARGET_ZDOTDIR/.zshrc"
    rm -rf "$stage_dir"
  fi

  # Preserve / template local.zsh
  if [ ! -f "$TARGET_ZDOTDIR/local.zsh" ] && [ -f "$SCRIPT_DIR/.config/zsh/local.zsh.example" ]; then
    cp "$SCRIPT_DIR/.config/zsh/local.zsh.example" "$TARGET_ZDOTDIR/local.zsh.example"
  fi

  # Harden permissions on real directory
  chmod 700 "$TARGET_ZDOTDIR" "$TARGET_STATE_HOME/zsh" "$TARGET_DATA_HOME/zsh" 2>/dev/null || true
  chmod 600 "$TARGET_ZDOTDIR/local.zsh" 2>/dev/null || true

  echo -e "  ${GREEN}[OK]${NC} Configuration files successfully activated."
}

# --- Install Pinned Plugins ---
install_plugins() {
  echo -e "\n${BLUE}${BOLD}[INFO] Installing pinned ZSH plugins...${NC}"
  local lockfile="$SCRIPT_DIR/plugins.lock"
  if [ ! -f "$lockfile" ]; then
    echo -e "  ${YELLOW}[WARN] plugins.lock not found. Skipping plugin downloads.${NC}"
    return 0
  fi

  mkdir -p "$TARGET_DATA_HOME/zsh/plugins"
  while IFS=$'\t' read -r name repo commit entrypoint; do
    [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
    local pdir="$TARGET_DATA_HOME/zsh/plugins/$name"
    if [ ! -d "$pdir" ]; then
      echo -e "  [INFO] Cloning $name ($commit)..."
      if git clone --quiet "https://github.com/${repo}.git" "$pdir" 2>/dev/null; then
        git -C "$pdir" checkout --quiet "$commit" 2>/dev/null || true
        echo -e "  ${GREEN}[OK]${NC} $name installed at $commit"
      fi
    else
      echo -e "  ${GREEN}[OK]${NC} $name already present"
    fi
  done < "$lockfile"
}

# --- Synchronize Root User ---
sync_root_configuration() {
  echo -e "\n${BLUE}${BOLD}[INFO] Synchronizing configuration to /root/...${NC}"
  local root_home="/root"
  local root_config="$root_home/.config/zsh"
  local root_state="$root_home/.local/state/zsh"
  local root_cache="$root_home/.cache/oh-my-posh/themes"

  run_sudo mkdir -p "$root_config/themes" "$root_state" "$root_cache" "$root_home/.local/bin"
  run_sudo cp "$SCRIPT_DIR/.zshenv" "$root_home/.zshenv"
  run_sudo cp -r "$SCRIPT_DIR/.config/zsh/"* "$root_config/"
  run_sudo cp "$SCRIPT_DIR/.config/zsh/.zshenv" "$root_config/.zshenv"
  run_sudo cp "$SCRIPT_DIR/.config/zsh/.zshrc" "$root_config/.zshrc"

  # Force Tokyo theme for root
  echo "tokyo" | run_sudo tee "$root_state/current_theme" >/dev/null

  run_sudo chown -R root:root "$root_config" "$root_state" "$root_cache" "$root_home/.zshenv" 2>/dev/null || true
  run_sudo chmod 700 "$root_config" "$root_state" 2>/dev/null || true
  echo -e "  ${GREEN}[OK]${NC} Root user configured with Tokyo theme."
}

# --- Main Execution Flow ---
main() {
  parse_args "$@"
  resolve_paths
  detect_platform

  if [ "$LIST_BACKUPS" = true ]; then
    list_backups
    exit 0
  fi

  if [ -n "$RESTORE_BACKUP_ID" ]; then
    restore_backup "$RESTORE_BACKUP_ID"
    exit 0
  fi

  echo -e "${CYAN}${BOLD}"
  echo "================================================================"
  echo "          ZSH Dotfiles Universal Installer"
  echo "================================================================"
  echo -e "${NC}"
  echo -e "${BLUE}${BOLD}[INFO] System:${NC} ${GREEN}${OS}${NC} (Mode: ${YELLOW}${INSTALL_MODE}${NC}, Target: ${YELLOW}${TARGET_HOME}${NC})"

  if [ "$DRY_RUN" = true ]; then
    echo -e "\n${YELLOW}${BOLD}[DRY-RUN PLAN]${NC}"
    echo "  1. Target ZDOTDIR: $TARGET_ZDOTDIR"
    echo "  2. Target .zshenv: $TARGET_ZSHENV"
    echo "  3. Installation Mode: $INSTALL_MODE"
    echo "  4. Skip Dependencies: $SKIP_DEPS"
    echo "  5. Root Synchronization: $SYNC_ROOT"
    echo -e "\n${GREEN}[OK] Dry run finished. No files were modified.${NC}"
    exit 0
  fi

  # 1. Dependency installation prompt / handling
  if [ "$SKIP_DEPS" = false ]; then
    local do_deps=true
    if [ "$UNATTENDED" = false ]; then
      read -r -p "[PROMPT] Install recommended packages and tools? (Y/n): " prompt_deps
      [[ "$prompt_deps" =~ ^[nN]$ ]] && do_deps=false
    fi
    [ "$do_deps" = true ] && install_packages
  fi

  # 2. Transactional Backup
  create_backup

  # 3. Deploy Configuration
  deploy_configuration

  # 4. Install Plugins (if requested or standalone)
  if [ "$INSTALL_PLUGINS" = true ]; then
    install_plugins
  fi

  # 5. Root Sync
  if [ "$SYNC_ROOT" = true ]; then
    sync_root_configuration
  elif [ "$UNATTENDED" = false ]; then
    read -r -p "[PROMPT] Synchronize configuration to root with Tokyo theme? (y/N): " prompt_root
    [[ "$prompt_root" =~ ^[yYsS]$ ]] && sync_root_configuration
  fi

  # 6. Default Login Shell
  if [ "$CHANGE_SHELL" = true ] && [ "$UNATTENDED" = false ]; then
    local cur_shell
    cur_shell="$(basename "${SHELL:-sh}")"
    if [ "$cur_shell" != "zsh" ] && command -v zsh >/dev/null 2>&1; then
      read -r -p "[PROMPT] Set ZSH as your default login shell? (Y/n): " prompt_shell
      if [[ ! "$prompt_shell" =~ ^[nN]$ ]]; then
        local zsh_bin
        zsh_bin="$(command -v zsh)"
        run_sudo chsh -s "$zsh_bin" "$USER" 2>/dev/null || true
        echo -e "  ${GREEN}[OK]${NC} Default shell changed to $zsh_bin."
      fi
    fi
  fi

  echo -e "\n${GREEN}${BOLD}================================================================${NC}"
  echo -e "${GREEN}${BOLD}[OK] Installation complete successfully.${NC}"
  echo -e "To start your session, run: ${CYAN}${BOLD}zsh${NC}"
  echo -e "To manage themes, run: ${CYAN}${BOLD}posh-theme${NC}"
  echo -e "${GREEN}${BOLD}================================================================${NC}\n"
}

main "$@"
