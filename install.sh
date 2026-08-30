#!/usr/bin/env bash
# ==============================================================================
#  Super Perfil ZSH - Automated Installer Script
#  Repository: https://github.com/Merxxotas/zsh-dotfiles
# ==============================================================================

set -e

# --- Colores ---
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
echo "  ║          🚀 Super Perfil ZSH - Instalador Automático       ║"
echo "  ╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# --- 1. Verificación de Dependencias ---
echo -e "${BLUE}${BOLD}[1/5] Verificando dependencias recomendadas...${NC}"

check_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    echo -e "  ${GREEN}✓${NC} $1 encontrado"
  else
    echo -e "  ${YELLOW}⚠${NC} $1 no encontrado (Recomendado: $2)"
  fi
}

check_tool "zsh" "pacman -S zsh / apt install zsh"
check_tool "fzf" "pacman -S fzf / apt install fzf"
check_tool "bat" "pacman -S bat / apt install bat"
check_tool "eza" "pacman -S eza / cargo install eza"
check_tool "fd" "pacman -S fd / apt install fd-find"
check_tool "oh-my-posh" "curl -s https://ohmyposh.dev/install.sh | bash"
check_tool "atuin" "pacman -S atuin / curl https://setup.atuin.sh | sh"
check_tool "nvim" "pacman -S neovim / apt install neovim"

# --- 2. Creación de Directorios XDG ---
echo -e "\n${BLUE}${BOLD}[2/5] Creando directorios XDG...${NC}"
mkdir -p "$HOME/.config/zsh" "$HOME/.local/state/zsh" "$HOME/.cache/zsh"
echo -e "  ${GREEN}✓${NC} Directorios base configurados"

# --- 3. Despliegue de Archivos de Configuración ---
echo -e "\n${BLUE}${BOLD}[3/5] Desplegando archivos de configuración en ~/.config/zsh/...${NC}"
cp -r "$SCRIPT_DIR/.config/zsh/"* "$HOME/.config/zsh/"
cp "$SCRIPT_DIR/.config/zsh/.zshenv" "$HOME/.config/zsh/.zshenv"
cp "$SCRIPT_DIR/.config/zsh/.zshrc" "$HOME/.config/zsh/.zshrc"
cp "$SCRIPT_DIR/.zshenv" "$HOME/.zshenv"

# Asegurar permisos correctos
chmod -R go-w "$HOME/.config/zsh" 2>/dev/null || true
echo -e "  ${GREEN}✓${NC} Módulos y temas desplegados con éxito"

# --- 4. Sincronización Opcional para Usuario ROOT ---
echo -e "\n${BLUE}${BOLD}[4/5] Configuración para el usuario root${NC}"
read -p "  ¿Deseas sincronizar esta configuración para el usuario root con tema Tokyo? (s/N): " sync_root
if [[ "$sync_root" =~ ^[sSyY]$ ]]; then
  echo -e "  Aplicando configuración en /root/ (requiere sudo)..."
  sudo mkdir -p /root/.config /root/.local/state/zsh /root/.cache/zsh
  sudo cp -r "$HOME/.config/zsh" /root/.config/
  sudo cp "$HOME/.zshenv" /root/.zshenv
  sudo chown -R root:root /root/.config/zsh /root/.local/state/zsh /root/.cache/zsh /root/.zshenv
  sudo chmod -R go-w /root/.config/zsh 2>/dev/null || true
  echo -e "  ${GREEN}✓${NC} Usuario root configurado con tema Tokyo"
fi

# --- 5. Establecer ZSH como Shell Predeterminada ---
echo -e "\n${BLUE}${BOLD}[5/5] Establecer ZSH como Shell por defecto${NC}"
CURRENT_SHELL="$(basename "$SHELL")"
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
  read -p "  ¿Deseas cambiar tu shell por defecto a ZSH ahora? (s/N): " change_shell
  if [[ "$change_shell" =~ ^[sSyY]$ ]]; then
    ZSH_PATH="$(which zsh)"
    chsh -s "$ZSH_PATH"
    echo -e "  ${GREEN}✓${NC} Shell cambiada a $ZSH_PATH"
  fi
else
  echo -e "  ${GREEN}✓${NC} ZSH ya es tu shell actual"
fi

echo -e "\n${GREEN}${BOLD}🎉 ¡Instalación completada con éxito!${NC}"
echo -e "Para iniciar de inmediato, ejecuta: ${CYAN}${BOLD}zsh${NC}\n"
