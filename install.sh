#!/usr/bin/env bash
# ==============================================================================
#  ZSH Dotfiles - Automated Universal Installer
#  Compatible: Ubuntu, Debian, Arch, CachyOS, Fedora, RHEL, openSUSE, Alpine, Gentoo, macOS
#  Repository: https://github.com/Merxxotas/zsh-dotfiles
# ==============================================================================

set -e

# --- Colors ---
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

# --- Argument Parsing ---
UNATTENDED=false
USE_SYMLINK=false
SKIP_DEPS=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes|--unattended|--non-interactive)
      UNATTENDED=true
      ;;
    -s|--symlink)
      USE_SYMLINK=true
      ;;
    --no-deps|--skip-deps)
      SKIP_DEPS=true
      ;;
    -h|--help)
      echo "Usage: ./install.sh [OPTIONS]"
      echo "Options:"
      echo "  -y, --yes, --unattended   Execute in non-interactive mode without prompts"
      echo "  -s, --symlink             Link dotfiles directly to repository via symlinks"
      echo "  --no-deps, --skip-deps    Skip system dependencies and package installation"
      echo "  -h, --help                Show this help message"
      exit 0
      ;;
  esac
done


echo -e "${CYAN}${BOLD}"
echo "================================================================"
echo "          ZSH Dotfiles Universal Installer"
echo "================================================================"
echo -e "${NC}"

# --- 1. OS Detection ---
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  OS="$ID"
fi

echo -e "${BLUE}${BOLD}[INFO] Detected System:${NC} ${GREEN}${PRETTY_NAME:-$OS}${NC} (User: ${YELLOW}$USER${NC})"

# --- 2. Package Installation ---
echo -e "\n${BLUE}${BOLD}[INFO] Checking and installing dependencies...${NC}"

install_packages() {
  case "$OS" in
    ubuntu|debian|pop|linuxmint)
      echo -e "[INFO] Installing packages via apt..."
      run_sudo apt-get update -y || true
      run_sudo apt-get install -y zsh fzf bat fd-find curl git jq neovim unzip tar ffmpeg yt-dlp || true
      mkdir -p "$HOME/.local/bin"
      if command -v batcat >/dev/null 2>&1; then
        ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat" || true
        run_sudo ln -sf "$(command -v batcat)" "/usr/local/bin/bat" 2>/dev/null || true
      fi
      if command -v fdfind >/dev/null 2>&1; then
        ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd" || true
        run_sudo ln -sf "$(command -v fdfind)" "/usr/local/bin/fd" 2>/dev/null || true
      fi
      ;;
    arch|cachyos|manjaro|endeavouros)
      echo -e "[INFO] Installing packages via pacman..."
      run_sudo pacman -S --needed --noconfirm zsh fzf bat eza fd curl git neovim jq atuin unzip tar ffmpeg yt-dlp || true
      ;;
    fedora|rhel|centos|rocky|almalinux)
      echo -e "[INFO] Installing packages via dnf..."
      run_sudo dnf install -y --allowerasing zsh fzf bat eza fd-find curl git neovim jq atuin unzip tar ffmpeg yt-dlp || true
      if command -v fdfind >/dev/null 2>&1; then
        run_sudo ln -sf "$(which fdfind)" "/usr/local/bin/fd" 2>/dev/null || true
      fi
      ;;
    opensuse*|suse)
      echo -e "[INFO] Installing packages via zypper..."
      run_sudo zypper --non-interactive install -y zsh fzf bat eza fd curl git neovim jq atuin unzip tar ffmpeg yt-dlp || true
      ;;
    alpine)
      echo -e "[INFO] Installing packages via apk..."
      run_sudo apk update || true
      run_sudo apk add zsh fzf bat eza fd curl git neovim jq unzip tar shadow ffmpeg yt-dlp || true
      ;;
    gentoo)
      echo -e "[INFO] Checking packages for Gentoo..."
      if ! command -v zsh >/dev/null 2>&1; then
        run_sudo emerge --quiet app-shells/zsh || true
      fi
      if ! command -v git >/dev/null 2>&1; then
        run_sudo emerge --quiet dev-vcs/git || true
      fi
      if ! command -v curl >/dev/null 2>&1; then
        run_sudo emerge --quiet net-misc/curl || true
      fi
      ;;
    macos)
      echo -e "[INFO] Installing packages via brew..."
      brew install zsh fzf bat eza fd curl git neovim jq atuin ffmpeg yt-dlp || true
      ;;
    *)
      echo -e "${RED}[WARN] Generic Linux environment detected. Continuing with available binaries...${NC}"
      ;;
  esac
}

INSTALL_DEPS=true
if [[ "$SKIP_DEPS" == "true" ]]; then
  INSTALL_DEPS=false
elif [[ "$UNATTENDED" != "true" ]]; then
  read -r -p "[PROMPT] Install recommended dependencies automatically? (Y/n): " do_install
  if [[ "$do_install" =~ ^[nN]$ ]]; then
    INSTALL_DEPS=false
  fi
fi

if [[ "$INSTALL_DEPS" == "true" ]]; then
  install_packages

  # Install eza for Ubuntu/Debian if missing
  if ! command -v eza >/dev/null 2>&1 && [[ "$OS" =~ ^(ubuntu|debian|pop|linuxmint)$ ]]; then
    echo -e "[INFO] Installing eza..."
    run_sudo mkdir -p /etc/apt/keyrings || true
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | run_sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | run_sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null 2>&1 || true
    run_sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
    run_sudo apt-get update -y >/dev/null 2>&1 || true
    run_sudo apt-get install -y eza >/dev/null 2>&1 || true
  fi

  # Install yt-dlp standalone if missing
  if ! command -v yt-dlp >/dev/null 2>&1; then
    echo -e "[INFO] Installing yt-dlp standalone binary..."
    mkdir -p "$HOME/.local/bin"
    curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o "$HOME/.local/bin/yt-dlp" 2>/dev/null || true
    chmod a+rx "$HOME/.local/bin/yt-dlp" 2>/dev/null || true
    run_sudo cp "$HOME/.local/bin/yt-dlp" /usr/local/bin/ 2>/dev/null || true
  fi

  # Install Oh-My-Posh if missing
  if ! command -v oh-my-posh >/dev/null 2>&1; then
    echo -e "[INFO] Installing Oh-My-Posh binary..."
    mkdir -p "$HOME/.local/bin"
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" 2>/dev/null || true
    if [[ -f "$HOME/.local/bin/oh-my-posh" ]]; then
      run_sudo cp "$HOME/.local/bin/oh-my-posh" /usr/local/bin/ 2>/dev/null || true
    fi
  fi

  # Install Atuin if missing
  if ! command -v atuin >/dev/null 2>&1 && [[ ! -f "$HOME/.atuin/bin/atuin" ]]; then
    echo -e "[INFO] Installing Atuin binary..."
    curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh 2>/dev/null || true
    if [[ -f "$HOME/.atuin/bin/atuin" ]]; then
      run_sudo cp "$HOME/.atuin/bin/atuin" /usr/local/bin/ 2>/dev/null || true
    fi
  fi
else
  echo -e "[INFO] Skipping automated package downloads as requested."
fi

# --- 3. Backup Existing Configurations ---
echo -e "\n${BLUE}${BOLD}[INFO] Checking for existing configurations...${NC}"
backup_timestamp="$(date +%Y%m%d_%H%M%S)"

if [[ -e "$HOME/.config/zsh" || -L "$HOME/.config/zsh" ]]; then
  if ! [[ "$HOME/.config/zsh" -ef "$SCRIPT_DIR/.config/zsh" ]]; then
    echo -e "  ${YELLOW}[BACKUP]${NC} Backing up existing ~/.config/zsh to ~/.config/zsh.bak.${backup_timestamp}..."
    cp -r "$HOME/.config/zsh" "$HOME/.config/zsh.bak.${backup_timestamp}"
  fi
fi

if [[ -e "$HOME/.zshenv" || -L "$HOME/.zshenv" ]]; then
  if ! [[ "$HOME/.zshenv" -ef "$SCRIPT_DIR/.zshenv" ]]; then
    echo -e "  ${YELLOW}[BACKUP]${NC} Backing up existing ~/.zshenv to ~/.zshenv.bak.${backup_timestamp}..."
    cp "$HOME/.zshenv" "$HOME/.zshenv.bak.${backup_timestamp}"
  fi
fi

# --- 4. XDG Directories Setup ---
echo -e "\n${BLUE}${BOLD}[INFO] Initializing XDG directory hierarchy...${NC}"
mkdir -p "$HOME/.config/zsh/themes" "$HOME/.local/state/zsh" "$HOME/.cache/zsh" "$HOME/.local/bin"
echo -e "  ${GREEN}[OK]${NC} Base directories initialized."

# --- 5. Deploy Configuration Files ---
echo -e "\n${BLUE}${BOLD}[INFO] Deploying configuration modules...${NC}"

if [[ "$USE_SYMLINK" == "true" ]]; then
  echo -e "  ${BLUE}[INFO]${NC} Creating symbolic links to repository..."
  rm -rf "$HOME/.config/zsh"
  ln -sf "$SCRIPT_DIR/.config/zsh" "$HOME/.config/zsh"
  ln -sf "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"
else
  mkdir -p "$HOME/.config/zsh/themes"
  cp -r "$SCRIPT_DIR/.config/zsh/"* "$HOME/.config/zsh/"
  cp "$SCRIPT_DIR/.config/zsh/.zshenv" "$HOME/.config/zsh/.zshenv"
  cp "$SCRIPT_DIR/.config/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
  cp "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"
  if [[ ! -f "$HOME/.config/zsh/local.zsh" && -f "$SCRIPT_DIR/.config/zsh/local.zsh.example" ]]; then
    cp "$SCRIPT_DIR/.config/zsh/local.zsh.example" "$HOME/.config/zsh/local.zsh.example"
  fi
fi

chmod -R go-w "$HOME/.config/zsh" 2>/dev/null || true
echo -e "  ${GREEN}[OK]${NC} Modules, themes and helpers deployed successfully."


# --- 6. Root Configuration (Optional) ---
sync_root="n"
if [[ "$UNATTENDED" != "true" ]]; then
  echo -e "\n${BLUE}${BOLD}[INFO] Root user configuration${NC}"
  read -r -p "[PROMPT] Synchronize configuration to root with Tokyo theme? (y/N): " sync_root
fi

if [[ "$sync_root" =~ ^[sSyY]$ ]]; then
  echo -e "[INFO] Applying configuration to /root/..."
  run_sudo mkdir -p /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.local/bin
  run_sudo cp -r "$HOME/.config/zsh" /root/.config/
  run_sudo cp "$HOME/.zshenv" /root/.zshenv
  if [[ -f "$HOME/.local/bin/oh-my-posh" ]]; then
    run_sudo cp "$HOME/.local/bin/oh-my-posh" /usr/local/bin/ 2>/dev/null || true
  fi
  if [[ -f "$HOME/.local/bin/yt-dlp" ]]; then
    run_sudo cp "$HOME/.local/bin/yt-dlp" /usr/local/bin/ 2>/dev/null || true
  fi
  run_sudo chown -R root:root /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.zshenv 2>/dev/null || true
  run_sudo chmod -R go-w /root/.config/zsh 2>/dev/null || true
  echo -e "  ${GREEN}[OK]${NC} Root user configured successfully."
fi

# --- 7. Set Default Shell ---
CURRENT_SHELL="$(basename "$SHELL")"
if [[ "$CURRENT_SHELL" != "zsh" && "$UNATTENDED" != "true" ]]; then
  echo -e "\n${BLUE}${BOLD}[INFO] Default Shell Configuration${NC}"
  read -r -p "[PROMPT] Set ZSH as your default login shell? (Y/n): " change_shell
  if [[ ! "$change_shell" =~ ^[nN]$ ]]; then
    ZSH_PATH="$(command -v zsh)"
    run_sudo chsh -s "$ZSH_PATH" "$USER" 2>/dev/null || run_sudo usermod -s "$ZSH_PATH" "$USER" 2>/dev/null || true
    echo -e "  ${GREEN}[OK]${NC} Default shell changed to $ZSH_PATH."
  fi
fi

echo -e "\n${GREEN}${BOLD}================================================================${NC}"
echo -e "${GREEN}${BOLD}[OK] Installation complete.${NC}"
echo -e "To start your session, run: ${CYAN}${BOLD}zsh${NC}"
echo -e "To manage themes, run: ${CYAN}${BOLD}posh-theme${NC}"
echo -e "${GREEN}${BOLD}================================================================${NC}\n"
