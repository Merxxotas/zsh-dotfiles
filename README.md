# ⚡ Super Perfil ZSH (`zsh-dotfiles`)

<p align="center">
  <img src="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/clean-detailed.png" alt="Oh-My-Posh Preview" width="600" />
</p>

<p align="center">
  <b>Una configuración modular, minimalista y de alto rendimiento para ZSH.</b><br>
  Diseñada para desarrolladores exigentes, combinando la velocidad del cargador modular de Radley Lewis, la estética de Oh-My-Posh, búsqueda con Atuin y previsualizaciones enriquecidas con FZF-Tab.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Shell-ZSH-blue?style=flat-square&logo=gnu-bash" alt="Shell ZSH" />
  <img src="https://img.shields.io/badge/Prompt-Oh--My--Posh-purple?style=flat-square&logo=powershell" alt="Oh My Posh" />
  <img src="https://img.shields.io/badge/History-Atuin-green?style=flat-square&logo=sqlite" alt="Atuin" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="License" />
</p>

---

## 🌟 Características Destacadas (The "Wow" Factor)

1. **`FZF-Tab` con Previews Flotantes Dinámicos**:
   - `kill ` + <kbd>Tab</kbd> ➔ Menú interactivo con lista de procesos (`PID`, `%CPU`, `%MEM`, comando).
   - `cd ` / `z ` + <kbd>Tab</kbd> ➔ Árbol interactivo con iconos (`eza --tree`).
   - `bat ` / `nvim ` + <kbd>Tab</kbd> ➔ Previsualización de archivos con resaltado de sintaxis (`bat`).
   - `git checkout ` + <kbd>Tab</kbd> ➔ Grafo e historial de commits de cada rama.
   - `echo $` + <kbd>Tab</kbd> ➔ Inspección de variables de entorno en tiempo real.
2. **Abreviaciones en Tiempo Real (Estilo Fish con `zsh-abbr`)**:
   - Escribe `gs`, `gco`, `gaa`, `pac` o `lg` y presiona <kbd>Espacio</kbd> para ver la expansión visual instantánea (`git status -s`, `git checkout`, `sudo pacman -S`). Tu historial guarda el comando completo y limpio.
3. **Atuin Integrado**:
   - <kbd>Ctrl</kbd> + <kbd>R</kbd> o <kbd>↑</kbd> despliegan la interfaz TUI completa de **Atuin** con búsqueda difusa, sincronización, estadísticas de ejecución y filtros por directorio/sesión.
4. **Oh-My-Posh Dual con Temas Locales Offline**:
   - **Usuario Estándar**: [`clean-detailed`](./.config/zsh/themes/clean-detailed.omp.json) (sin colapsos molestos de `transient_prompt`).
   - **Usuario Root**: [`tokyo`](./.config/zsh/themes/tokyo.omp.json) (colores distintivos de superusuario con estado de memoria y host).
5. **Vi-Mode con Cursores Dinámicos (`zsh-vi-mode`)**:
   - Cursor de barra vertical (`|`) en modo inserción y bloque sólido (`█`) en modo normal con <kbd>Esc</kbd>.
6. **Magic Sudo (<kbd>Alt</kbd> + <kbd>S</kbd>)**:
   - Antepone o elimina `sudo ` de la línea de comandos actual al instante.
7. **Asistente Didáctico (`You-Should-Use`)**:
   - Si escribes comandos largos teniendo un alias disponible, la terminal te recuerda educadamente: `💡 Found existing alias: 'gs'`.
8. **Autopair Inteligente**:
   - Cierre, salto y borrado automático de pares de comillas `""`, `''` y paréntesis `()`, `[]`, `{}`.
9. **Super Helpers Universales**:
   - `take <directorio>`: Crea la estructura de carpetas y entra directamente (`mkdir -p && cd`).
   - `extract <archivo.*>`: Descompresor universal para `.tar.gz`, `.zip`, `.7z`, `.rar`, `.tar.xz`, `.zst`, etc.

---

## 🏛️ Arquitectura Modular (`~/.config/zsh`)

Toda la configuración respeta el estándar **XDG Base Directory** para mantener el directorio `~` limpio:

```
~/.config/zsh/
├── .zshenv                # Variables XDG, PATH consolidado, Atuin y variables de entorno
├── .zshrc                 # Orquestador, compinit -u, historial y paste highlight fix
├── aliases.zsh            # Abreviaciones zsh-abbr, alias de git, eza, yazi y gh multicuenta
├── bindings.zsh           # Vi-mode, Magic Sudo (Alt+S), hooks de Atuin y atajos
├── dev-env.zsh            # Entornos nvm, bun, pnpm, cargo, brew, gcloud, railway, atuin
├── fzf.zsh                # Buscadores FZF con preview bat (Ctrl+F, Ctrl+T)
├── fzf-tab.zsh            # Previews dinámicos para la tecla Tab
├── helpers.zsh            # Funciones take() y extract()
├── plugins.zsh            # Gestor autónomo sin dependencias y zplugin-update
├── prompt.zsh             # Selector de temas locales de Oh-My-Posh (merxx vs root)
└── themes/
    ├── clean-detailed.omp.json
    └── tokyo.omp.json
```

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
| `y` | Navegador **Yazi** con cambio de directorio al salir |

---

## 🚀 Instalación

### Requisitos Recomendados
- **Arch / CachyOS**:
  ```bash
  sudo pacman -S zsh fzf bat eza fd neovim atuin
  ```
- **Oh-My-Posh**:
  ```bash
  curl -s https://ohmyposh.dev/install.sh | bash
  ```

### Clonar e Instalar

```bash
git clone https://github.com/Merxxotas/zsh-dotfiles.git ~/Projects/zsh-dotfiles
cd ~/Projects/zsh-dotfiles
./install.sh
```

El script `install.sh` se encargará de:
1. Comprobar tus herramientas.
2. Desplegar los módulos en `~/.config/zsh`.
3. Ofrecer sincronización automática para el usuario `root`.
4. Establecer `zsh` como tu shell predeterminada (`chsh`).

---

## 🔄 Actualización de Plugins

Para actualizar todos los plugins de GitHub a sus últimas versiones:
```bash
zplugin-update
```

---

## 🧪 Casos de Prueba

Para probar paso a paso cada una de las funcionalidades implementadas, consulta la guía:
👉 [**TEST_SCENARIOS.md**](./TEST_SCENARIOS.md)

---

## 📄 Créditos y Agradecimientos

- Estructura base modular inspirada en [Radley Lewis](https://github.com/radleylewis/zsh).
- Motor de prompt: [Oh-My-Posh](https://ohmyposh.dev/).
- Historial sincronizado: [Atuin](https://atuin.sh/).
- Catálogo de plugins: [awesome-zsh-plugins](https://github.com/unixorn/awesome-zsh-plugins).
