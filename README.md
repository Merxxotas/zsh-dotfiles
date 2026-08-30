# ⚡ Super Perfil ZSH Universal (`zsh-dotfiles`)

<p align="center">
  <img src="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.png" alt="Oh-My-Posh Preview" width="600" />
</p>

<p align="center">
  <b>Configuración modular, minimalista y de alto rendimiento para ZSH.</b><br>
  100% portable y universal: compatible con <b>Ubuntu 24.04 LTS</b>, Debian, <b>CachyOS/Arch</b>, Fedora, macOS y servidores VPS.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Shell-ZSH-blue?style=flat-square&logo=gnu-bash" alt="Shell ZSH" />
  <img src="https://img.shields.io/badge/Ubuntu-24.04%20LTS-orange?style=flat-square&logo=ubuntu" alt="Ubuntu 24.04" />
  <img src="https://img.shields.io/badge/Arch-Linux-1793d1?style=flat-square&logo=arch-linux" alt="Arch Linux" />
  <img src="https://img.shields.io/badge/Prompt-Oh--My--Posh-purple?style=flat-square&logo=powershell" alt="Oh My Posh" />
  <img src="https://img.shields.io/badge/History-Atuin-green?style=flat-square&logo=sqlite" alt="Atuin" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License" />
</p>

---

## 🌟 Características Principales

1. **`FZF-Tab` con Previews Flotantes Dinámicos**:
   - `kill ` + <kbd>Tab</kbd> ➔ Menú interactivo con lista de procesos (`PID`, `%CPU`, `%MEM`, comando).
   - `cd ` / `z ` + <kbd>Tab</kbd> ➔ Árbol interactivo con iconos (`eza --tree`).
   - `bat ` / `nvim ` + <kbd>Tab</kbd> ➔ Previsualización de archivos con resaltado de sintaxis (`bat`).
   - `git checkout ` + <kbd>Tab</kbd> ➔ Grafo e historial de commits de cada rama.
   - `echo $` + <kbd>Tab</kbd> ➔ Inspección de variables de entorno en tiempo real.
2. **🎨 Selector Interactivo de Temas (`posh-theme`)**:
   - Cambia y previsualiza cualquier tema de Oh-My-Posh con un menú interactivo difuso (`posh-theme`) o por nombre directo (`posh-theme catppuccin`).
   - Descarga automáticamente temas oficiales y guarda tu preferencia de forma persistente.
3. **Abreviaciones en Tiempo Real (Estilo Fish con `zsh-abbr`)**:
   - Escribe `gs`, `gco`, `gaa`, `pac` o `lg` y presiona <kbd>Espacio</kbd> para ver la expansión visual instantánea (`git status -s`, `git checkout`, `sudo pacman -S`). Tu historial guarda el comando completo y limpio.
4. **Atuin Integrado**:
   - <kbd>Ctrl</kbd> + <kbd>R</kbd> o <kbd>↑</kbd> despliegan la interfaz TUI completa de **Atuin** con búsqueda difusa, sincronización, estadísticas de ejecución y filtros por directorio/sesión.
5. **Oh-My-Posh Dual con Temas Locales Offline**:
   - **Usuario Estándar**: [`clean-detailed`](./.config/zsh/themes/clean-detailed.omp.json) (sin colapsos molestos de `transient_prompt`).
   - **Usuario Root**: [`tokyo`](./.config/zsh/themes/tokyo.omp.json) (colores distintivos de superusuario con estado de memoria y host).
6. **Vi-Mode con Cursores Dinámicos (`zsh-vi-mode`)**:
   - Cursor de barra vertical (`|`) en modo inserción y bloque sólido (`█`) en modo normal con <kbd>Esc</kbd>.
7. **Magic Sudo (<kbd>Alt</kbd> + <kbd>S</kbd>)**:
   - Antepone o elimina `sudo ` de la línea de comandos actual al instante.
8. **Asistente Didáctico (`You-Should-Use`)**:
   - Si escribes comandos largos teniendo un alias disponible (`git status -s`), la terminal te recuerda: `💡 Found existing alias: 'gs'`.
9. **Autopair Inteligente**:
   - Cierre, salto y borrado automático de pares de comillas `""`, `''` y paréntesis `()`, `[]`, `{}`.
10. **Super Helpers Universales**:
   - `take <directorio>`: Crea la estructura de carpetas y entra directamente (`mkdir -p && cd`).
   - `extract <archivo.*>`: Descompresor universal para `.tar.gz`, `.zip`, `.7z`, `.rar`, `.tar.xz`, `.zst`, etc.

---

## 🎨 Cómo Cambiar de Tema con `posh-theme`

El perfil incluye el comando integrado **`posh-theme`**:

```bash
# 1. Selector Interactivo con FZF
posh-theme

# 2. Cambiar directamente a un tema específico
posh-theme catppuccin
posh-theme dracula
posh-theme tokyo
posh-theme clean-detailed
posh-theme agnoster
posh-theme space
```

> **Nota**: Si el tema no está descargado en tu máquina, `posh-theme` lo descarga automáticamente del repositorio oficial de Oh-My-Posh, limpia cualquier configuración de `transient_prompt` y lo activa de inmediato sin reiniciar la terminal.

---

## 🚀 Instalación en Cualquier Máquina (Ubuntu 24.04, VPS, Arch, Fedora)

### 1. Clonar el repositorio
```bash
git clone https://github.com/Merxxotas/zsh-dotfiles.git ~/Projects/zsh-dotfiles
cd ~/Projects/zsh-dotfiles
```

### 2. Ejecutar el instalador inteligente
```bash
./install.sh
```

El script detectará automáticamente tu distribución (**Ubuntu / Debian / Arch / Fedora / macOS**):
- Instalará todas las herramientas necesarias (`zsh`, `fzf`, `bat`, `fd`, `eza`, `oh-my-posh`, `atuin`).
- Configurará enlaces simbólicos en Ubuntu para `bat` y `fd`.
- Desplegará la configuración XDG en `~/.config/zsh`.
- Ofrecerá sincronizar opcionalmente el usuario `root` con el tema Tokyo.
- Configurará `zsh` como shell por defecto.

---

## ⌨️ Atajos de Teclado (Keybindings)

| Atajo | Acción |
| :--- | :--- |
| <kbd>Ctrl</kbd> + <kbd>R</kbd> | Búsqueda mágica e interactiva en el historial con **Atuin** |
| <kbd>Tab</kbd> | Menú emergente de completado con **FZF-Tab** y preview dinámico |
| <kbd>Alt</kbd> + <kbd>S</kbd> | **Magic Sudo**: Antepone o quita `sudo ` al comando actual |
| <kbd>Ctrl</kbd> + <kbd>F</kbd> | Selector difuso de archivos locales (excluye ocultos) con preview `bat` |
| <kbd>Ctrl</kbd> + <kbd>T</kbd> | Selector difuso completo de archivos con preview `bat` |
| <kbd>Ctrl</kbd> + <kbd>→</kbd> / <kbd>←</kbd> | Salto rápido palabra por palabra |
| <kbd>Alt</kbd> + <kbd>→</kbd> | Aceptar una palabra de la autosugerencia en gris |
| <kbd>Ctrl</kbd> + <kbd>\</kbd> | Activar / desactivar autosugerencias |
| <kbd>Esc</kbd> | Cambiar a modo comando en **Vi-Mode** (cursor bloque `█`) |
| `i` / `a` | Volver a modo inserción en **Vi-Mode** (cursor barra `|`) |

---

## ⏩ Abreviaciones y Alias Rápidos

| Abreviación | Comando Expandido |
| :--- | :--- |
| `gs` | `git status -s` |
| `gss` | `git status` |
| `gco` | `git checkout` |
| `ga` / `gaa` | `git add` / `git add --all` |
| `gc` / `gca` | `git commit -m` / `git commit --amend` |
| `gp` / `gpl` | `git push` / `git pull` |
| `gb` / `gd` | `git branch` / `git diff` |
| `lg` | `lazygit` |
| `pac` / `pacu` | `sudo pacman -S` / `sudo pacman -Syu` |
| `yay` | `paru -S` |
| `sc` / `scu` | `sudo systemctl` / `systemctl --user` |
| `take <dir>` | `mkdir -p <dir> && cd <dir>` |
| `extract <file>` | Descompresión universal automática |
| `posh-theme` | Selector interactivo de temas de Oh-My-Posh |
| `y` | Navegador **Yazi** con cambio de directorio al salir |

---

## 🔄 Actualización de Plugins

Para actualizar todos los plugins de GitHub a sus últimas versiones:
```bash
zplugin-update
```

---

## 🧪 Casos de Prueba

Para probar paso a paso cada una de las funcionalidades implementadas:
👉 [**TEST_SCENARIOS.md**](./TEST_SCENARIOS.md)
