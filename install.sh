#!/usr/bin/env bash
# ==============================================================================
#  Super Perfil ZSH - Universal Multi-Distribution Installer
#  Supported: Ubuntu 24.04+, Debian, Arch/CachyOS, Fedora, macOS, VPS
#  Repository: https://github.com/Merxxotas/zsh-dotfiles
# ==============================================================================

set -e

# --- Colores ANSI ---
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${CYAN}${BOLD}"
echo "  ╔════════════════════════════════════════════════════════════╗"
echo "  ║      🚀 Super Perfil ZSH - Instalador Universal Linux      ║"
echo "  ║         (Ubuntu, Debian, Arch, Fedora, macOS, VPS)         ║"
echo "  ╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# --- 1. Detección de Distribución ---
OS="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="macos"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  OS="$ID"
  OS_LIKE="${ID_LIKE:-$ID}"
fi

echo -e "${BLUE}${BOLD}[1/6] Sistema detectado:${NC} ${GREEN}${PRETTY_NAME:-$OS}${NC} (Usuario: ${YELLOW}$USER${NC})"

# --- 2. Instalación Automática de Paquetes ---
echo -e "\n${BLUE}${BOLD}[2/6] Verificación e instalación de dependencias...${NC}"

install_packages() {
  case "$OS" in
    ubuntu|debian|pop|linuxmint)
      echo -e "  Instalando paquetes via ${CYAN}apt${NC}..."
      sudo apt update -y
      sudo apt install -y zsh fzf bat fd-find curl git jq neovim unzip tar
      # Symlinks para Ubuntu/Debian donde bat es batcat y fd es fdfind
      mkdir -p "$HOME/.local/bin"
      command -v batcat >/dev/null 2>&1 && ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
      command -v fdfind >/dev/null 2>&1 && ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
      ;;
    arch|cachyos|manjaro|endeavouros)
      echo -e "  Instalando paquetes via ${CYAN}pacman${NC}..."
      sudo pacman -S --needed --noconfirm zsh fzf bat eza fd curl git neovim jq atuin unzip tar
      ;;
    fedora|rhel|centos)
      echo -e "  Instalando paquetes via ${CYAN}dnf${NC}..."
      sudo dnf install -y zsh fzf bat eza fd-find curl git neovim jq atuin unzip tar
      ;;
    macos)
      echo -e "  Instalando paquetes via ${CYAN}brew${NC}..."
      brew install zsh fzf bat eza fd curl git neovim jq atuin
      ;;
    *)
      echo -e "  ${YELLOW}Distribución no estándar. Continuando con herramientas existentes...${NC}"
      ;;
  esac
}

read -p "  ¿Deseas instalar las dependencias recomendadas para tu sistema automáticamente? (S/n): " do_install
if [[ ! "$do_install" =~ ^[nN]$ ]]; then
  install_packages
fi

# Instalar eza en Ubuntu/Debian si no existe
if ! command -v eza >/dev/null 2>&1 && [[ "$OS" =~ ^(ubuntu|debian|pop|linuxmint)$ ]]; then
  echo -e "  Instalando ${CYAN}eza${NC} (modern ls)..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg 2>/dev/null || true
  echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null 2>&1 || true
  sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list 2>/dev/null || true
  sudo apt update -y >/dev/null 2>&1 || true
  sudo apt install -y eza >/dev/null 2>&1 || true
fi

# Instalar Oh-My-Posh si no existe
if ! command -v oh-my-posh >/dev/null 2>&1; then
  echo -e "  Instalando ${CYAN}Oh-My-Posh${NC}..."
  mkdir -p "$HOME/.local/bin"
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
fi

# Instalar Atuin si no existe
if ! command -v atuin >/dev/null 2>&1 && [[ ! -f "$HOME/.atuin/bin/atuin" ]]; then
  echo -e "  Instalando ${CYAN}Atuin${NC} (shell history sync)..."
  curl --proto '=https' --tlsv1.2 -sSf https://setup.atuin.sh | sh
fi

# --- 3. Creación de Directorios XDG ---
echo -e "\n${BLUE}${BOLD}[3/6] Creando directorios XDG...${NC}"
mkdir -p "$HOME/.config/zsh/themes" "$HOME/.local/state/zsh" "$HOME/.cache/zsh" "$HOME/.local/bin"
echo -e "  ${GREEN}✓${NC} Directorios base configurados"

# --- 4. Despliegue de Archivos de Configuración ---
echo -e "\n${BLUE}${BOLD}[4/6] Desplegando archivos de configuración en ~/.config/zsh/...${NC}"
cp -r "$SCRIPT_DIR/.config/zsh/"* "$HOME/.config/zsh/"
cp "$SCRIPT_DIR/.config/zsh/.zshenv" "$HOME/.config/zsh/.zshenv"
cp "$SCRIPT_DIR/.config/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
cp "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"

chmod -R go-w "$HOME/.config/zsh" 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Módulos, temas y helpers desplegados"

# --- 5. Sincronización Opcional para Usuario ROOT ---
echo -e "\n${BLUE}${BOLD}[5/6] Configuración para el usuario root${NC}"
read -p "  ¿Deseas sincronizar esta configuración para el usuario root con tema Tokyo? (s/N): " sync_root
if [[ "$sync_root" =~ ^[sSyY]$ ]]; then
  echo -e "  Aplicando configuración en /root/ (requiere sudo)..."
  sudo mkdir -p /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.local/bin
  sudo cp -r "$HOME/.config/zsh" /root/.config/
  sudo cp "$HOME/.zshenv" /root/.zshenv
  
  # Si oh-my-posh está en ~/.local/bin, enlazarlo para root
  if [[ -f "$HOME/.local/bin/oh-my-posh" ]]; then
    sudo cp "$HOME/.local/bin/oh-my-posh" /usr/local/bin/ 2>/dev/null || true
  fi

  sudo chown -R root:root /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.zshenv
  sudo chmod -R go-w /root/.config/zsh 2>/dev/null || true
  echo -e "  ${GREEN}✓${NC} Usuario root configurado con tema Tokyo"
fi

# --- 6. Establecer ZSH como Shell Predeterminada ---
echo -e "\n${BLUE}${BOLD}[6/6] Establecer ZSH como Shell por defecto${NC}"
CURRENT_SHELL="$(basename "$SHELL")"
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
  read -p "  ¿Deseas cambiar tu shell por defecto a ZSH ahora? (S/n): " change_shell
  if [[ ! "$change_shell" =~ ^[nN]$ ]]; then
    ZSH_PATH="$(which zsh)"
    chsh -s "$ZSH_PATH" || sudo chsh -s "$ZSH_PATH" "$USER"
    echo -e "  ${GREEN}✓${NC} Shell cambiada a $ZSH_PATH"
  fi
else
  echo -e "  ${GREEN}✓${NC} ZSH ya es tu shell actual"
fi

echo -e "\n${GREEN}${BOLD}🎉 ¡Super Perfil ZSH instalado con éxito en tu sistema!${NC}"
echo -e "Para comenzar a usarlo inmediatamente, ejecuta: ${CYAN}${BOLD}zsh${NC}"
echo -e "Para cambiar o probar temas de Oh-My-Posh ejecuta: ${CYAN}${BOLD}posh-theme${NC}\n"
