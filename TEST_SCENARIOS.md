# 🧪 Casos de Prueba: Guía Completa del "Super Perfil" ZSH

Esta guía detalla los escenarios de prueba para validar cada una de las funcionalidades avanzadas implementadas en tu perfil de ZSH.

---

### 🌟 Escenario 1: `FZF-Tab` con Previews Flotantes Dinámicos
*El autocompletado tradicional con `Tab` ahora es un menú interactivo emergente con vista previa.*

1. **Preview de Procesos (`kill` / `pkill`)**:
   * Escribe: `kill ` *(con un espacio)* y presiona <kbd>Tab</kbd>.
   * **Resultado**: Aparece una ventana flotante mostrando los procesos activos con su PID, consumo de CPU, memoria y comando completo. Puedes escribir para filtrar y presionar <kbd>Enter</kbd> para seleccionar el PID.
2. **Preview de Directorios con árbol e iconos (`cd` / `z`)**:
   * Escribe: `cd ` y presiona <kbd>Tab</kbd>.
   * **Resultado**: Al moverte por las carpetas, verás a la derecha el árbol con iconos (`eza --tree`) del contenido interno de cada directorio.
3. **Preview de Archivos con resaltado de sintaxis (`nvim` / `bat` / `cat`)**:
   * Escribe: `bat ` o `nvim ` y presiona <kbd>Tab</kbd>.
   * **Resultado**: Se abre una vista previa en tiempo real mostrando el contenido del archivo con números de línea y colores.
4. **Preview de Variables de Entorno**:
   * Escribe: `echo $` y presiona <kbd>Tab</kbd>.
   * **Resultado**: Al navegar por las variables (`PATH`, `USER`, `EDITOR`), verás su valor actual a la derecha.
5. **Preview de Git (`git checkout` / `git log`)**:
   * Dentro de cualquier repositorio Git, escribe: `git checkout ` y presiona <kbd>Tab</kbd>.
   * **Resultado**: Verás el historial de commits y el grafo de cada rama antes de cambiarte a ella.

---

### ⚡ Escenario 2: Abreviaciones en Tiempo Real (Estilo Fish)
*Las abreviaciones se expanden visualmente en la línea al presionar espacio, guardando el comando completo en tu historial.*

1. Escribe `gs` y presiona <kbd>Espacio</kbd> ➔ Se expande inmediatamente a `git status -s`.
2. Escribe `lg` y presiona <kbd>Espacio</kbd> ➔ Se expande inmediatamente a `lazygit`.
3. Escribe `gco` y presiona <kbd>Espacio</kbd> ➔ Se expande a `git checkout`.
4. Escribe `gaa` y presiona <kbd>Espacio</kbd> ➔ Se expande a `git add --all`.
5. Escribe `pac` y presiona <kbd>Espacio</kbd> ➔ Se expande a `sudo pacman -S`.
6. Escribe `sc` y presiona <kbd>Espacio</kbd> ➔ Se expande a `sudo systemctl`.

---

### 🪄 Escenario 3: Magic Sudo (<kbd>Alt</kbd> + <kbd>S</kbd>)
*Evita tener que navegar al principio de la línea o usar `sudo !!` cuando olvidas permisos de administrador.*

1. Escribe cualquier comando que requiera root: `pacman -Syu` *(no presiones Enter)*.
2. Presiona <kbd>Alt</kbd> + <kbd>s</kbd>.
3. **Resultado**: La línea se convierte instantáneamente en `sudo pacman -Syu`. Si vuelves a presionar <kbd>Alt</kbd> + <kbd>s</kbd>, quita el `sudo`.

---

### 💡 Escenario 4: Asistente Didáctico (`You-Should-Use`)
*Entrena tu memoria muscular cuando escribes comandos largos teniendo un alias disponible.*

1. Dentro de cualquier repositorio Git, escribe manualmente: `git status -s` y presiona <kbd>Enter</kbd>.
2. **Resultado**: Además de ejecutar el comando, Zsh te mostrará un aviso didáctico:
   `💡 Found existing alias: 'gs'`

---

### 📜 Escenario 5: Atuin (Historial Mágico y Búsqueda Interactiva)
*Tu motor Atuin sincronizado y con interfaz TUI completa.*

1. **Búsqueda Atuin**: Presiona <kbd>Ctrl</kbd> + <kbd>R</kbd> o <kbd>↑</kbd> (Flecha Arriba).
2. **Resultado**: Se abre la interfaz interactiva de **Atuin**, mostrando historial con fecha/hora relativa, duración de ejecución, código de salida, directorio y host.
3. Puedes presionar <kbd>Tab</kbd> dentro de Atuin para cambiar el modo de filtro (Global / Host / Directorio actual / Sesión).

---

### 🔒 Escenario 6: Autopair Inteligente
*Gestión automática de comillas y paréntesis.*

1. Escribe `"` ➔ Automáticamente se escribe `""` con el cursor en medio.
2. Escribe texto dentro y luego vuelve a presionar `"` ➔ En lugar de duplicar la comilla, **salta hacia afuera**.
3. Si estás dentro de un par vacío `()` o `""` y presionas <kbd>Backspace</kbd> ➔ Borra ambos caracteres al mismo tiempo.

---

### ✏️ Escenario 7: Vi-Mode con Cursores Vivos
*Edición modal estilo Neovim directamente en tu prompt.*

1. Al escribir normalmente, observa que el cursor es una **barra vertical (`|`)** (Modo inserción).
2. Presiona la tecla <kbd>Esc</kbd> ➔ El cursor cambia a un **bloque sólido (`█`)** (Modo normal de Vim).
3. En modo normal puedes usar comandos de Vim como `b` (palabra atrás), `w` (palabra adelante), `dd` (borrar línea) o `ciw` (cambiar palabra).
4. Presiona `i` para volver al modo inserción y el cursor regresará a la barra `|`.

---

### 🧰 Escenario 8: Super Helpers (`take` y `extract`)

1. **Helper `take`**:
   * Ejecuta: `take /tmp/prueba_super_perfil/subdirectorio`
   * **Resultado**: Crea toda la estructura de carpetas (`mkdir -p`) y entra directamente en ella (`cd`).
2. **Helper `extract`**:
   * Ejecuta `extract archivo.tar.gz` o `extract archivo.zip`
   * **Resultado**: Descomprime automáticamente cualquier formato (`tar`, `gz`, `bz2`, `zip`, `7z`, `rar`, `zst`) sin necesidad de memorizar banderas como `-xvzf`.

---

### 🔍 Escenario 9: Selector de Archivos FZF con Preview `bat`

1. **Selector de archivos limpios**: Presiona <kbd>Ctrl</kbd> + <kbd>F</kbd> para buscar archivos en el directorio actual (excluyendo archivos ocultos y carpetas `.git`) con vista previa en tiempo real con `bat`.
2. **Selector completo**: Presiona <kbd>Ctrl</kbd> + <kbd>T</kbd> para buscar entre todos los archivos.

---

### 🎨 Escenario 10: Temas Oh-My-Posh (Opción A: Prompt Fijo y Sin Colapsos)

1. **Usuario `merxx`**:
   * Abre tu terminal: verás el tema **`clean-detailed`** local con iconos, tiempo de ejecución y estado git. Al presionar <kbd>Enter</kbd>, el prompt se mantiene completo y alineado.
2. **Usuario `root`**:
   * Ejecuta `sudo -i zsh`: verás el tema **`tokyo`** local con colores de superusuario y sin falsos avisos de error.

---

### 🔄 Escenario 11: Actualizaciones en un solo comando
*Para actualizar todos los plugins del Super Perfil a sus últimas versiones de GitHub:*

* Ejecuta: `zplugin-update`
* **Resultado**: Actualiza automáticamente todos los repositorios en `~/.config/zsh/plugins/` en paralelo con `git pull --ff-only`.
