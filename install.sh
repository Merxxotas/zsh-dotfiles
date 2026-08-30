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

# --- Argument Parsing ---
UNATTENDED=false
for arg in "$@"; do
  case "$arg" in
    -y|--yes|--unattended|--non-interactive)
      UNATTENDED=true
      ;;
    -h|--help)
      echo "Usage: ./install.sh [OPTIONS]"
      echo "Options:"
      echo "  -y, --yes, --unattended   Execute in non-interactive mode without prompts"
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
      sudo apt update -y
      sudo apt install -y zsh fzf bat fd-find curl git jq neovim unzip tar
      mkdir -p "$HOME/.local/bin"
      command -v batcat >/dev/null 2>&1 && ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
      command -v fdfind >/dev/null 2>&1 && ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
      ;;
    arch|cachyos|manjaro|endeavouros)
      echo -e "[INFO] Installing packages via pacman..."
      sudo pacman -S --needed --noconfirm zsh fzf bat eza fd curl git neovim jq atuin unzip tar
      ;;
    fedora|rhel|centos|rocky|almalinux)
      echo -e "[INFO] Installing packages via dnf..."
      sudo dnf install -y zsh fzf bat eza fd-find curl git neovim jq atuin unzip tar || true
      ;;
    opensuse*|suse)
      echo -e "[INFO] Installing packages via zypper..."
      sudo zypper --non-interactive install zsh fzf bat eza fd curl git neovim jq atuin unzip tar || true
      ;;
    alpine)
      echo -e "[INFO] Installing packages via apk..."
      sudo apk update && sudo apk add zsh fzf bat eza fd curl git neovim jq unzip tar shadow
      ;;
    gentoo)
      echo -e "[INFO] Checking packages for Gentoo..."
      command -v zsh >/dev/null 2>&1 || sudo emerge --quiet app-shells/zsh
      command -v git >/dev/null 2>&1 || sudo emerge --quiet dev-vcs/git
      command -v curl >/dev/null 2>&1 || sudo emerge --quiet net-misc/curl
      ;;
    macos)
      echo -e "[INFO] Installing packages via brew..."
      brew install zsh fzf bat eza fd curl git neovim jq atuin
      ;;
    *)
      echo -e "[WARN] Generic Linux environment detected. Continuing with available binaries..."
      ;;
  esac
}

if [[ "$UNATTENDED" == "true" ]]; then
  install_packages || true
else
  read -r -p "[PROMPT] Install recommended dependencies automatically? (Y/n): " do_install
  if [[ ! "$do_install" =~ ^[nN]$ ]]; then
    install_packages
  fi
fi

# Install eza for Ubuntu/Debian if missing
if ! command -v eza >/dev/null 2>&1 && [[ "$OS" =~ ^(ubuntu|debian|pop|linuxmint)$ ]]; then
  echo -e "[INFO] Installing eza..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null 2>&1 || true
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
  sudo apt update -y >/dev/null 2>&1 || true
  sudo apt install -y eza >/dev/null 2>&1 || true
fi

# Install Oh-My-Posh if missing
if ! command -v oh-my-posh >/dev/null 2>&1; then
  echo -e "[INFO] Installing Oh-My-Posh binary..."
  mkdir -p "$HOME/.local/bin"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin" || true
fi

# Install Atuin if missing
if ! command -v atuin >/dev/null 2>&1 && [[ ! -f "$HOME/.atuin/bin/atuin" ]]; then
  echo -e "[INFO] Installing Atuin binary..."
  curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh || true
fi

# --- 3. XDG Directories Setup ---
echo -e "\n${BLUE}${BOLD}[INFO] Creating XDG directory hierarchy...${NC}"
mkdir -p "$HOME/.config/zsh/themes" "$HOME/.local/state/zsh" "$HOME/.cache/zsh" "$HOME/.local/bin"
echo -e "  ${GREEN}[OK]${NC} Base directories initialized."

# --- 4. Deploy Configuration Files ---
echo -e "\n${BLUE}${BOLD}[INFO] Deploying configuration modules to ~/.config/zsh/...${NC}"
cp -r "$SCRIPT_DIR/.config/zsh/"* "$HOME/.config/zsh/"
cp "$SCRIPT_DIR/.config/zsh/.zshenv" "$HOME/.config/zsh/.zshenv"
cp "$SCRIPT_DIR/.config/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
cp "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"

chmod -R go-w "$HOME/.config/zsh" 2>/dev/null || true
echo -e "  ${GREEN}[OK]${NC} Modules, themes and helpers deployed successfully."

# --- 5. Root Configuration (Optional) ---
sync_root="n"
if [[ "$UNATTENDED" != "true" ]]; then
  echo -e "\n${BLUE}${BOLD}[INFO] Root user configuration${NC}"
  read -r -p "[PROMPT] Synchronize configuration to root with Tokyo theme? (y/N): " sync_root
fi

if [[ "$sync_root" =~ ^[sSyY]$ ]]; then
  echo -e "[INFO] Applying configuration to /root/..."
  sudo mkdir -p /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.local/bin
  sudo cp -r "$HOME/.config/zsh" /root/.config/
  sudo cp "$HOME/.zshenv" /root/.zshenv
  if [[ -f "$HOME/.local/bin/oh-my-posh" ]]; then
    sudo cp "$HOME/.local/bin/oh-my-posh" /usr/local/bin/ 2>/dev/null || true
  fi
  sudo chown -R root:root /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.zshenv
  sudo chmod -R go-w /root/.config/zsh 2>/dev/null || true
  echo -e "  ${GREEN}[OK]${NC} Root user configured successfully."
fi

# --- 6. Set Default Shell ---
CURRENT_SHELL="$(basename "$SHELL")"
if [[ "$CURRENT_SHELL" != "zsh" && "$UNATTENDED" != "true" ]]; then
  echo -e "\n${BLUE}${BOLD}[INFO] Default Shell Configuration${NC}"
  read -r -p "[PROMPT] Set ZSH as your default login shell? (Y/n): " change_shell
  if [[ ! "$change_shell" =~ ^[nN]$ ]]; then
    ZSH_PATH="$(which zsh)"
    chsh -s "$ZSH_PATH" 2>/dev/null || sudo chsh -s "$ZSH_PATH" "$USER"
    echo -e "  ${GREEN}[OK]${NC} Default shell changed to $ZSH_PATH."
  fi
fi

echo -e "\n${GREEN}${BOLD}================================================================${NC}"
echo -e "${GREEN}${BOLD}[OK] Installation complete.${NC}"
echo -e "To start your session, run: ${CYAN}${BOLD}zsh${NC}"
echo -e "To manage themes, run: ${CYAN}${BOLD}posh-theme${NC}"
echo -e "${GREEN}${BOLD}================================================================${NC}\n"
