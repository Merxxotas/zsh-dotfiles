# Plan integral de remediacion

> - Estado: completado (auditado y verificado en main)
> - Linea base auditada: `b2fc77c`
> - Entrega final: `1a3dc6e` (Pull Request #1)
> - Alcance: instalador, configuracion Zsh, plugins, utilidades multimedia, seguridad, pruebas, CI y documentacion
> - Objetivo: eliminar los fallos funcionales y de seguridad conocidos, y convertir las afirmaciones de compatibilidad en evidencia reproducible

## 1. Resultado esperado

Este plan busca llevar el proyecto desde una configuracion personal funcional, pero con riesgos importantes en instalacion y reproducibilidad, hasta una distribucion de dotfiles que cumpla estas propiedades:

1. Instalar nunca modifica un checkout, un destino externo enlazado ni una configuracion previa sin un respaldo recuperable.
2. Los modos copia y symlink pueden instalarse, repetirse y alternarse en cualquier direccion.
3. Los valores XDG personalizados son respetados de extremo a extremo.
4. Un fallo obligatorio produce codigo distinto de cero y nunca imprime un mensaje de exito global.
5. El inicio de Zsh no descarga ni ejecuta codigo remoto.
6. Toda descarga ejecutable esta fijada a una version y verificada criptograficamente.
7. Las funciones publicas validan argumentos, no se bloquean y devuelven estados fiables.
8. Las pruebas automatizadas cubren las rutas destructivas, los casos negativos y las transiciones de estado.
9. La matriz CI y la documentacion describen exactamente las plataformas realmente verificadas.
10. Una instalacion o una prueba no deja el repositorio modificado.

### Criterio global de salida

La remediacion se considera completa cuando:

- [x] Todos los elementos `P0` y `P1` de este documento estan cerrados.
- [x] Las pruebas unitarias y de integracion pasan sin red, salvo jobs explicitamente marcados como pruebas externas.
- [x] Las matrices soportadas pasan como usuario normal y, cuando corresponda, como root.
- [x] No se ejecutan `curl | sh`, `curl | bash`, referencias `latest` ni ramas flotantes para codigo ejecutable.
- [x] La instalacion no escribe en el repositorio ni sigue symlinks externos de manera implicita.
- [x] Todos los mensajes `[OK]` corresponden a una operacion verificada con codigo `0`.
- [x] README, escenarios, workflows y comportamiento real coinciden.

## 2. Prioridades

| Prioridad | Significado | Regla de entrega |
|---|---|---|
| `P0` | Puede perder datos, bloquear una shell, ejecutar codigo no confiable o declarar exito falso en una operacion critica | Debe corregirse antes de agregar nuevas funciones |
| `P1` | Rompe un flujo documentado, portabilidad, recuperacion o evidencia de CI | Debe cerrarse antes de la siguiente version estable |
| `P2` | Inconsistencia, degradacion de experiencia, deuda de mantenimiento o documentacion | Puede entregarse despues de los P0/P1, pero requiere seguimiento |

## 3. Inventario trazable de hallazgos

| ID | Prioridad | Componente | Fallo a cubrir | Evidencia actual |
|---|---|---|---|---|
| `INS-01` | P0 | Instalador | El modo copia sigue symlinks de configuracion y sobrescribe destinos externos; el backup puede ser otro enlace no recuperable | `install.sh:198-230` |
| `INS-02` | P0 | Instalador | La transicion symlink -> copia intenta copiar el repositorio sobre si mismo | `install.sh:199`, `install.sh:227` |
| `INS-03` | P1 | Instalador | La transicion copia -> symlink deja de cargar `local.zsh` | `install.sh:220-234` |
| `INS-04` | P1 | Backups | Timestamps con resolucion de un segundo permiten colisiones y sobrescritura/anidamiento | `install.sh:196-208` |
| `INS-05` | P1 | Instalador | Symlinks rotos o un archivo regular en `~/.config/zsh` impiden instalar incluso en modo symlink | `install.sh:198-224` |
| `INS-06` | P1 | Permisos | `chmod -R` atraviesa el symlink y cambia permisos dentro del checkout | `install.sh:236` |
| `INS-07` | P1 | Root | Sincronizar root desde modo symlink falla y no respalda la configuracion previa de root | `install.sh:247-260` |
| `INS-08` | P2 | Resolucion de ruta | Ejecutar `install.sh` por medio de un symlink busca los recursos junto al enlace y no junto al repositorio real | `install.sh:19` |
| `INS-09` | P1 | CLI | Opciones desconocidas se ignoran; un typo en `--no-deps` puede activar instalaciones | `install.sh:36-57` |
| `INS-10` | P0 | Errores | Fallos de paquetes/descargas son ocultados con `|| true` y se anuncia instalacion completa | `install.sh:85-188`, `install.sh:275-279` |
| `INS-11` | P0 | Seguridad | Scripts remotos, `latest` y contenido de `main` se instalan sin version/checksum | `install.sh:156-185` |
| `INS-12` | P1 | XDG | El runtime preserva XDG personalizado, pero el instalador escribe siempre en `~/.config/zsh` | `install.sh:198-236`, `.zshenv:11-14` |
| `INS-13` | P1 | Dependencias | No existe preflight ni verificacion final de comandos obligatorios y opcionales | `install.sh:78-192` |
| `INS-14` | P2 | Portabilidad | Queda uso de `which`; Debian usa `wget`/`gpg` sin garantizar que existan | `install.sh:105`, `install.sh:156` |
| `RUN-01` | P0 | `vdl` | Una opcion sin valor (`-f`, `-q`, `-c`, `-o`) entra en bucle infinito | `media.zsh:227-249` |
| `RUN-02` | P1 | `vdl` | `--quality` permite una resolucion mayor a la maxima documentada | `media.zsh:261-287` |
| `RUN-03` | P1 | Temas | `posh-theme` persiste e imprime exito antes de validar Oh My Posh | `prompt.zsh:105-108` |
| `RUN-04` | P1 | Temas | El nombre de tema se interpola en rutas y codigo Python sin validacion suficiente | `prompt.zsh:39-108` |
| `RUN-05` | P2 | Aliases | El fallback `ls --color=auto` no es portable a macOS/BSD | `aliases.zsh:58-68` |
| `RUN-06` | P2 | Aliases | La deteccion de `grep --color=auto` interpreta codigo `1` como falta de soporte | `aliases.zsh:96-98` |
| `RUN-07` | P2 | Helpers | `extract` devuelve error correctamente, pero imprime `[OK]` cuando extrajo cero archivos | `helpers.zsh:69-72` |
| `RUN-08` | P2 | Inicio | Se ejecutan procesos externos redundantes y aparecen avisos `zle`/`tput` sin TTY en algunas distros | `.zshenv`, `.zshrc`, `dev-env.zsh` |
| `PLG-01` | P0 | Plugins | El primer inicio clona y ejecuta ocho repositorios sin commits fijados | `plugins.zsh:13-45` |
| `PLG-02` | P1 | Plugins | `zplugin-update` avanza ramas upstream sin lockfile ni revision previa | `plugins.zsh:29-34` |
| `PLG-03` | P2 | Documentacion | El escenario llama paralela a una actualizacion que es secuencial | `TEST_SCENARIOS.md:152-156` |
| `CI-01` | P1 | Cobertura | CI automatiza solo instalacion, inicio, `take`, tema y symlinks | `.github/workflows/ci-*.yml` |
| `CI-02` | P1 | Usuarios | Las matrices de containers se ejecutan solo como root | `.github/workflows/ci-*.yml` |
| `CI-03` | P1 | Aserciones | La prueba de tema valida existencia, no contenido ni inicializacion real | workflows de Debian y Arch |
| `CI-04` | P1 | Compatibilidad | README/matrices no coinciden: Debian Testing, Fedora Latest, Gentoo y macOS | `README.md:247-252` |
| `CI-05` | P1 | Reproducibilidad | Actions, imagenes y paquetes usan etiquetas/referencias mutables | `.github/workflows/*.yml` |
| `CI-06` | P2 | Lint | No hay `actionlint`, validacion JSON en CI, Markdown lint ni pruebas runtime | `.github/workflows/lint.yml` |
| `CI-07` | P1 | Senal | Errores como `wget` ausente o avisos de startup aparecen en logs sin fallar jobs | logs actuales de CI |
| `DOC-01` | P1 | Documentacion | Las plataformas declaradas exceden las verificadas | `README.md:3`, `README.md:247-252` |
| `DOC-02` | P2 | Documentacion | `--no-deps`, restauracion, red, checksums y limitaciones no estan documentados | `README.md:151-180` |
| `DOC-03` | P2 | Pruebas | `TEST_SCENARIOS.md` es un checklist manual, no una suite reproducible | `TEST_SCENARIOS.md` |

## 4. Principios de implementacion

Las soluciones deben respetar estas reglas para no cambiar un fallo por otro:

1. **No confiar en el tipo aparente de una ruta.** Clasificar explicitamente archivos, directorios, symlinks validos, symlinks rotos y enlaces al propio repositorio.
2. **Respaldar antes de crear, borrar o seguir una ruta.** La fase de backup debe terminar completamente antes del despliegue.
3. **No usar el checkout como almacenamiento mutable.** Temas descargados, plugins, estado y configuracion privada deben vivir fuera del repositorio.
4. **Preparar y validar antes de activar.** Crear el nuevo estado en staging; activar con `mv`/symlink solo cuando todo sea valido.
5. **Fallar de forma explicita.** Un comando obligatorio que falla termina la operacion; uno opcional genera un warning estructurado y queda reflejado en el resumen.
6. **No mezclar red con inicio de shell.** Las descargas son acciones explicitas del instalador o de un comando de mantenimiento.
7. **Las pruebas no usan el HOME real.** Toda integracion se ejecuta con un directorio temporal y herramientas simuladas.
8. **La compatibilidad se demuestra.** Una plataforma solo se etiqueta como soportada si tiene un job verde que prueba el flujo relevante.

## 5. Fase 0: red de seguridad y baseline

Esta fase debe entregarse primero. Su objetivo es capturar el comportamiento defectuoso actual como pruebas rojas, para que el rediseno posterior tenga evidencia objetiva.

### 5.1 Estructura de pruebas propuesta

```text
tests/
|-- helpers/
|   |-- assertions.bash
|   |-- fake-command.bash
|   |-- fixtures.bash
|   `-- sandbox.bash
|-- fixtures/
|   |-- archives/
|   |-- media/
|   |-- themes/
|   `-- yt-dlp/
|-- installer/
|   |-- clean-install.bats
|   |-- transitions.bats
|   |-- backups.bats
|   |-- symlinks.bats
|   |-- dependencies.bats
|   |-- root-sync.bats
|   `-- xdg.bats
|-- runtime/
|   |-- env.bats
|   |-- helpers.bats
|   |-- media.bats
|   |-- prompt.bats
|   |-- plugins.bats
|   `-- startup.bats
`-- interactive/
    |-- bindings.zsh
    |-- completion.zsh
    `-- zle.zsh
```

### 5.2 Herramientas

- Usar `bats-core` para integracion del instalador y funciones invocadas desde procesos Zsh aislados.
- Usar `zsh -f` para cargar modulos sin contaminar la prueba con la configuracion del host.
- Usar `zpty` para las pruebas que realmente necesitan TTY/ZLE.
- Simular `sudo`, gestores de paquetes, `curl`, `wget`, `git`, `ffmpeg`, `yt-dlp`, `oh-my-posh`, `fzf` y `date` mediante un `PATH` temporal controlado.
- Mantener un fixture multimedia minimo generado de forma determinista; no descargar videos en PRs.
- Anadir timeouts obligatorios a comandos que procesan argumentos o esperan entrada.

### 5.3 Baseline obligatorio

- [x] Prueba roja para symlink externo sobrescrito (`INS-01`).
- [x] Prueba roja para symlink -> copia (`INS-02`).
- [x] Prueba roja que detecte perdida funcional de `local.zsh` (`INS-03`).
- [x] Prueba roja para colision de backups con `date` fijo (`INS-04`).
- [x] Prueba roja para `vdl URL -f` con timeout (`RUN-01`).
- [x] Prueba roja para `posh-theme` sin binario (`RUN-03`).
- [x] Prueba roja con `XDG_CONFIG_HOME` personalizado (`INS-12`).
- [x] Prueba roja que fuerce fallo del gestor de paquetes (`INS-10`).
- [x] Prueba roja que confirme que un inicio offline no intenta `git clone` (`PLG-01`).

### Criterios de aceptacion de la fase 0

- Las pruebas reproducen los fallos sin escribir fuera de su sandbox.
- Cada prueba termina en menos de 10 segundos.
- `teardown` valida que no queden procesos, montajes ni directorios temporales.
- El estado Git antes y despues de la suite es identico.

## 6. Fase 1: rediseno seguro del instalador

### 6.1 Separar el instalador en etapas

Refactorizar [install.sh](./install.sh) alrededor de funciones pequenas con contratos claros:

```text
main
|-- parse_args
|-- resolve_script_dir
|-- resolve_xdg_paths
|-- detect_platform
|-- preflight
|-- build_install_plan
|-- confirm_plan
|-- install_dependencies        (opcional y explicito)
|-- backup_existing_targets
|-- stage_configuration
|-- activate_configuration
|-- verify_installation
|-- configure_login_shell       (opcional)
`-- print_summary
```

No activar `set -x`. Considerar `set -Eeuo pipefail`, pero solo despues de eliminar referencias a variables opcionales no protegidas y anadir un `trap` de error que informe etapa, comando y codigo.

Usar `umask 077` mientras se crean backups, estado, locks y configuracion privada. Aplicar permisos mas abiertos solo a archivos que realmente deban ser legibles por otros usuarios.

### 6.2 Resolver rutas una sola vez

Definir al inicio y no reconstruir rutas de manera dispersa:

```bash
TARGET_HOME="${HOME:?HOME is required}"
TARGET_CONFIG_HOME="${XDG_CONFIG_HOME:-$TARGET_HOME/.config}"
TARGET_CACHE_HOME="${XDG_CACHE_HOME:-$TARGET_HOME/.cache}"
TARGET_DATA_HOME="${XDG_DATA_HOME:-$TARGET_HOME/.local/share}"
TARGET_STATE_HOME="${XDG_STATE_HOME:-$TARGET_HOME/.local/state}"
TARGET_ZDOTDIR="$TARGET_CONFIG_HOME/zsh"
TARGET_ZSHENV="$TARGET_HOME/.zshenv"
```

Acciones:

- [x] Usar estas rutas en backup, creacion XDG, despliegue, verificacion y mensajes.
- [x] Resolver `SCRIPT_DIR` siguiendo el symlink del propio script hasta el archivo real.
- [x] Canonicalizar solo rutas existentes; no depender de `realpath` GNU para rutas futuras.
- [x] Rechazar `HOME` vacio, `/`, el checkout o una ruta no escribible.
- [x] Resolver el usuario objetivo con `id`, no confiar ciegamente en `$USER`; tratar explicitamente la ejecucion mediante `sudo ./install.sh`.
- [x] No confiar en `$SHELL` para confirmar la shell de login; consultar la base de usuarios y verificar despues de `chsh`.
- [x] Anadir `assert_safe_target` antes de cualquier `rm`, `mv`, `chmod` o reemplazo.
- [x] Prohibir que un destino resuelto sea el repositorio salvo que sea el symlink esperado en modo symlink.
- [x] Comprobar que las rutas XDG son absolutas y rechazar valores relativos.
- [x] Validar existencia e integridad de todos los archivos fuente antes de crear backups.
- [x] Comprobar permisos de los directorios padre y espacio libre suficiente para staging + backup.

### 6.3 Parser de argumentos estricto

Interfaz propuesta:

```text
./install.sh [--mode copy|symlink] [--yes] [--no-deps]
             [--dry-run] [--sync-root] [--no-change-shell]
```

Mantener `-s/--symlink` como alias compatible para `--mode symlink` durante al menos una version.

- [x] Rechazar opciones desconocidas con codigo `2` y mostrar ayuda corta.
- [x] Validar que toda opcion con valor tenga valor.
- [x] Detectar opciones incompatibles o duplicadas con valores diferentes.
- [x] Anadir `--dry-run`: imprimir plan, tipos de destino, backups y comandos privilegiados sin cambiar estado.
- [x] Hacer que `--yes` responda prompts, pero no implique ignorar errores.
- [x] Hacer que `--no-deps` aparezca en README y CI.

### 6.4 Clasificar destinos antes de actuar

Implementar una funcion que devuelva exactamente uno de estos estados:

| Estado | Ejemplo | Tratamiento esperado |
|---|---|---|
| `absent` | La ruta no existe | No requiere backup |
| `regular_file` | `.zshenv` normal | Snapshot antes de reemplazar |
| `directory` | Configuracion Zsh normal | Snapshot recursivo antes de reemplazar/mezclar |
| `symlink_to_repo` | Instalacion `-s` actual | Migrar el enlace de directorio legacy al modelo por archivo; materializar para transicion a copia |
| `symlink_external_valid` | Enlace a otro dotfile manager | Guardar exactamente el enlace y su destino textual; nunca leer/escribir a traves del enlace |
| `symlink_broken` | Destino eliminado | Guardar el texto del enlace; retirar de forma segura antes de desplegar |
| `unexpected_type` | FIFO, socket, dispositivo | Abortar y pedir intervencion manual |

La clasificacion debe usar `-L` antes de `-e`, ya que un symlink roto no satisface `-e`.

### 6.5 Estado de instalacion y concurrencia

Mantener un manifiesto de propiedad bajo state, fuera del arbol configurable:

```text
$XDG_STATE_HOME/zsh-dotfiles/
|-- install-state.tsv
|-- managed-files.tsv
`-- install.lock/
```

El estado debe incluir:

- Version de esquema.
- Modo activo (`copy` o `symlink`).
- Ruta canonica y commit del repositorio fuente.
- HOME y cuatro rutas XDG efectivas.
- Lista de archivos administrados, tipo esperado y checksum cuando aplique.
- Ultimo backup completado.
- Resultado de la ultima instalacion verificada.

Reglas:

- [x] Tratar el manifiesto como datos; nunca cargarlo con `source` o `eval`.
- [x] Validar claves, columnas, tipos y rutas antes de usarlo.
- [x] Distinguir archivos administrados de `local.zsh` y otros archivos del usuario.
- [x] Detectar modificaciones locales en archivos administrados y respaldarlas antes de actualizar.
- [x] Detectar archivos que dejaron de ser administrados sin borrar archivos locales homonimos.
- [x] Escribir estado mediante temporal + `mv` solo despues de verificar la instalacion activa.
- [x] Adquirir un lock con `mkdir` atomico antes de planificar cambios.
- [x] Registrar PID en el lock y tratar locks obsoletos de manera conservadora.
- [x] Liberar staging y lock mediante `trap` ante exito, error o senal.

### 6.6 Backups unicos y recuperables

Mover los backups a un directorio estable fuera del arbol activo:

```text
$XDG_STATE_HOME/zsh/backups/
`-- 20260901T132527-0500-<random>/
    |-- manifest.tsv
    |-- zshenv/
    |   |-- metadata
    |   `-- content
    `-- zdotdir/
        |-- metadata
        `-- content/
```

Requisitos:

- [x] Crear el directorio con `mktemp -d` dentro de `backups/`; no depender solo de segundos.
- [x] Guardar ruta original, tipo, permisos, ownership cuando sea legible y destino de symlink.
- [x] Para symlinks externos, guardar el enlace sin dereferenciarlo y registrar su destino textual; no copiar, recorrer ni modificar el referente.
- [x] No seguir symlinks internos recursivos sin limite; detectar ciclos.
- [x] Crear un manifiesto legible por shell y humano.
- [x] Verificar que el snapshot existe y es legible antes de continuar.
- [x] Si el backup falla, abortar antes de tocar el destino.
- [x] Implementar `./install.sh --list-backups` y `--restore <id>` o un script `scripts/restore-backup.sh` probado.
- [x] Documentar recuperacion manual aun si existe comando automatico.

### 6.7 Configuracion privada independiente del checkout

El directorio completo no puede ser a la vez symlink al repositorio y contenedor seguro de secretos locales. Mantener `ZDOTDIR` como directorio real en ambos modos y reservar una ruta local estable:

```text
$XDG_CONFIG_HOME/zsh/local.zsh
```

Cambios:

- [x] Tratar `local.zsh` como archivo no administrado y nunca reemplazarlo con el ejemplo.
- [x] Durante la migracion desde el enlace de directorio legacy, preservar byte por byte cualquier `local.zsh` existente solo despues de crear backup.
- [x] Si el `local.zsh` legacy esta dentro del checkout, copiarlo con permisos privados al ZDOTDIR real y advertir que el ejemplar legacy debe retirarse manualmente.
- [x] Nunca copiar secretos dentro del repositorio aunque esten ignorados por Git.
- [x] Mantener `local.zsh.example` como archivo administrado; no convertirlo automaticamente en configuracion activa.
- [x] Aplicar permisos privados (`0600`) cuando se migre una configuracion real.
- [x] Verificar preservacion en copy -> symlink, symlink -> copy y reruns.

### 6.8 Redefinir el modo symlink por archivo

La opcion recomendada es no enlazar `$XDG_CONFIG_HOME/zsh` completo. Crear un directorio real y enlazar solo los archivos administrados:

```text
$XDG_CONFIG_HOME/zsh/
|-- .zshrc       -> <repo>/.config/zsh/.zshrc
|-- aliases.zsh  -> <repo>/.config/zsh/aliases.zsh
|-- helpers.zsh  -> <repo>/.config/zsh/helpers.zsh
|-- local.zsh       (archivo local real, no administrado)
`-- themes/
    |-- clean-detailed.omp.json -> <repo>/.../clean-detailed.omp.json
    `-- ...
```

Ventajas:

- `local.zsh` permanece en la misma ruta en copia y symlink.
- Plugins, tema actual, caches y archivos descargados nunca terminan dentro del checkout.
- La transicion symlink -> copia se realiza archivo por archivo sin copiar la fuente sobre si misma.
- Los permisos pueden aplicarse al directorio real sin atravesar enlaces administrados.
- El manifiesto puede distinguir archivos locales de archivos propiedad del instalador.

Requisitos:

- [x] Enlazar cada archivo de configuracion incluido y cada tema versionado de forma explicita.
- [x] Mantener `$HOME/.zshenv` como copia o symlink administrado segun el modo elegido.
- [x] No enlazar directorios donde el runtime deba escribir.
- [x] Guardar plugins bajo `$XDG_DATA_HOME/zsh/plugins`.
- [x] Guardar `current_theme` bajo `$XDG_STATE_HOME/zsh/current_theme`.
- [x] Guardar temas descargados bajo `$XDG_CACHE_HOME/oh-my-posh/themes`.
- [x] Migrar instalaciones legacy que enlazan el directorio completo sin modificar el repositorio.
- [x] Actualizar CI: validar enlaces por archivo y archivos locales regulares, no `test -L ~/.config/zsh`.

### 6.9 Staging, activacion y rollback

Para modo copia:

1. Crear un staging bajo el mismo filesystem que `TARGET_ZDOTDIR`.
2. Copiar al staging todos los archivos, incluidos los dotfiles, con una lista explicita o una herramienta portable.
3. Validar sintaxis Zsh y JSON dentro del staging.
4. Aplicar permisos al staging, no al checkout.
5. Retirar/mover el destino anterior solo despues del backup verificado.
6. Activar con `mv` dentro del mismo filesystem.
7. Verificar que `TARGET_ZDOTDIR/.zshrc` y `TARGET_ZSHENV` apuntan/copian al contenido esperado.

Para modo symlink por archivo:

1. Verificar que el repositorio contiene todos los archivos obligatorios.
2. Crear un ZDOTDIR real en staging y symlinks por archivo con nombres/destinos validados.
3. Reemplazar destinos solo despues del backup y preflight.
4. No ejecutar `chmod -R` sobre el enlace.
5. Verificar cada archivo administrado con `readlink` y el manifiesto.

La activacion de ZDOTDIR y `.zshenv` forma una sola transaccion logica. Registrar cada paso confirmado y, ante `ERR`, `INT`, `TERM` o `HUP`, restaurar en orden inverso. No debe existir una ventana donde uno de los dos destinos este activo y el otro perdido sin instrucciones de recuperacion.

### 6.10 Matriz obligatoria de transiciones

| Estado inicial | Modo solicitado | Resultado |
|---|---|---|
| Ausente | Copia | Instalacion nueva |
| Ausente | Symlink | Instalacion nueva enlazada |
| Copia gestionada | Copia | Rerun idempotente; backup solo si cambia contenido o politica definida |
| Symlink al repo | Symlink | No-op idempotente |
| Copia gestionada | Symlink | Backup, preservar local, activar enlace |
| Symlink al repo | Copia | Materializar en staging, retirar enlace, activar copia |
| Directorio externo/no gestionado | Cualquier modo | Backup completo y confirmacion/`--yes` |
| Symlink externo valido | Cualquier modo | Backup exacto del enlace, retirar solo el enlace, no tocar ni recorrer el destino externo |
| Symlink roto | Cualquier modo | Guardar metadata, retirar enlace, instalar |
| Archivo donde se espera directorio | Cualquier modo | Backup y reemplazo controlado o error explicito |
| Directorio donde se espera `.zshenv` | Cualquier modo | Backup + error/confirmacion explicita; nunca crear un archivo interno silenciosamente |
| FIFO, socket o dispositivo | Cualquier modo | Abortar sin leer, seguir ni borrar el objeto |

Cada celda debe tener una prueba automatizada que valide contenido, tipo de ruta, codigo de salida, backup y preservacion de configuracion privada.

### 6.11 Sincronizacion de root

No copiar desde `~/.config/zsh`, porque puede ser symlink o contener configuracion privada del usuario.

- [x] Construir una instalacion de root desde el staging/repositorio fuente.
- [x] Usar rutas XDG de root resueltas explicitamente.
- [x] Aplicar el mismo clasificador, backup y activacion que para el usuario.
- [x] No copiar `local.zsh` del usuario a root por defecto.
- [x] Permitir un archivo local de root separado.
- [x] Respaldar `/root/.zshenv` y `/root/.config/zsh` antes de cambiar.
- [x] Verificar ownership `root:root` y permisos sin seguir symlinks.
- [x] Hacer que un fallo de root sync falle esa operacion y se refleje en el resumen.

### 6.12 Verificacion y resumen

Al terminar, verificar como minimo:

- `zsh` existe si se solicito instalacion completa.
- `.zshenv` existe y establece `ZDOTDIR` esperado con el XDG objetivo.
- `.zshrc` pasa `zsh -n`.
- Los modulos requeridos existen.
- Los temas incluidos son JSON valido.
- El modo activo coincide con lo solicitado.
- El repositorio no cambio de permisos ni contenido.

El resumen debe separar:

```text
[OK] Configuration deployed
[OK] Existing configuration backed up: <id>
[WARN] Optional command not installed: atuin
[ERROR] Required dependency failed: zsh
```

Solo imprimir `Installation complete` y devolver `0` si todas las etapas obligatorias pasaron.

## 7. Fase 2: dependencias y cadena de suministro

### 7.1 Clasificar dependencias

Mantener una unica tabla de capacidades, en lugar de listas distintas por gestor de paquetes:

| Clase | Ejemplos | Politica de fallo |
|---|---|---|
| Requerida | `zsh`, `git` para instalar plugins de forma explicita | Abortar instalacion completa si no esta disponible |
| Recomendada | `fzf`, `eza`, `bat`, `fd`, `oh-my-posh` | Advertir; la configuracion debe degradar limpiamente |
| Funcional | `ffmpeg`, `yt-dlp`, extractores de archivos | La funcion afectada devuelve un error claro al usarse |
| Desarrollo | `shellcheck`, `bats`, `actionlint`, linters | Requerida solo en CI/desarrollo |

Acciones:

- [x] Crear una funcion `check_capabilities` que produzca una tabla de presentes/ausentes.
- [x] Usar nombres de capacidad (`fd`) y mapearlos a paquetes por plataforma (`fd-find`, `fd`, etc.).
- [x] No considerar que el gestor termino bien solo por estar envuelto en `|| true`.
- [x] Despues de instalar, volver a comprobar los binarios requeridos.
- [x] Diferenciar claramente "paquete no disponible" de "instalacion fallo".

### 7.2 Politica de instalaciones remotas

Orden preferido:

1. Paquete oficial de la distribucion.
2. Release upstream fijado a una version y checksum.
3. Instruccion manual documentada.

No ejecutar scripts remotos por pipe. Para cualquier artefacto descargado:

1. Resolver version explicita.
2. Descargar a un directorio creado con `mktemp -d`.
3. Usar `curl --fail --location --proto '=https' --tlsv1.2`.
4. Descargar checksum/firma desde una fuente fijada o almacenar el checksum revisado en el repositorio.
5. Verificar con `sha256sum` o `shasum -a 256` segun plataforma.
6. Validar formato/arquitectura basica.
7. Instalar primero en `$HOME/.local/bin`; escribir en `/usr/local/bin` solo con una opcion explicita.
8. Limpiar temporales mediante `trap`.

### 7.3 Lockfile de herramientas

Anadir un archivo revisable, por ejemplo `dependencies.lock`, con estos campos:

```text
name<TAB>version<TAB>os<TAB>arch<TAB>url<TAB>sha256
```

Requisitos:

- [x] No evaluar contenido del lockfile como shell.
- [x] Rechazar registros incompletos, URLs no HTTPS y hashes con formato invalido.
- [x] Revisar cambios de version como PRs separados.
- [x] Automatizar comprobacion de disponibilidad y checksum sin actualizar automaticamente el lockfile.
- [x] Documentar el procedimiento de actualizacion y rollback.

### 7.4 Cambios por herramienta

#### eza

- Preferir paquete de la distribucion.
- Si se agrega un repositorio APT, usar HTTPS y una clave/fingerprint fijados.
- Instalar explicitamente las herramientas necesarias para importar la clave o eliminar ese fallback.
- No descargar una clave desde `main` durante cada instalacion.

#### yt-dlp

- Fijar una version conocida.
- Descargar el artefacto apropiado por OS/arquitectura.
- Verificar checksum antes de `chmod` o copia.
- Evitar copiar automaticamente a `/usr/local/bin`.

#### Oh My Posh

- Sustituir `curl | bash` por release fijado y checksum, o paquete de plataforma.
- Verificar `oh-my-posh version` despues de instalar.
- Mantener temas incluidos funcionales aun sin red.

#### Atuin

- Sustituir `curl | sh` por paquete/release fijado.
- No considerar Atuin requisito para iniciar Zsh.
- Verificar que el init generado corresponde a la version instalada.

### 7.5 Modelo de privilegios

- [x] No ejecutar `sudo` si no se va a instalar una dependencia del sistema.
- [x] Si no hay `sudo` y el usuario no es root, explicar que operacion requiere privilegios y abortar solo esa etapa.
- [x] No caer silenciosamente a ejecutar un comando privilegiado sin privilegios.
- [x] Mostrar todos los comandos privilegiados en `--dry-run`.
- [x] Solicitar confirmacion separada para modificar repositorios de paquetes.
- [x] Dar preferencia a instalaciones user-local.

### Criterios de aceptacion de la fase 2

- No existen patrones `curl ... | sh`, `curl ... | bash`, `/latest/` o descargas ejecutables desde ramas flotantes.
- Corromper un checksum impide instalar y devuelve error.
- Una descarga HTTP 404 no deja un archivo ejecutable parcial.
- Un gestor de paquetes simulado con fallo produce codigo no cero cuando falta una dependencia requerida.
- `--no-deps` no invoca red, `sudo` ni gestores de paquetes.

## 8. Fase 3: plugins deterministas y sin red al iniciar

### 8.1 Separar instalacion de carga

Cambiar [plugins.zsh](./.config/zsh/plugins.zsh) para que el inicio haga exclusivamente:

1. Resolver el directorio de plugins bajo `$XDG_DATA_HOME/zsh/plugins`.
2. Comprobar que el plugin fijado existe.
3. Cargar el archivo esperado.
4. Registrar de forma compacta los plugins ausentes sin intentar red.

La instalacion debe ser una accion explicita:

```text
./install.sh --install-plugins
# o
zplugin-install
```

### 8.2 Lockfile de plugins

Crear `plugins.lock` con, como minimo:

```text
name<TAB>repository<TAB>commit<TAB>entrypoint
```

Para cada plugin:

- [x] Usar commit SHA completo, no rama ni tag mutable.
- [x] Clonar/fetch en staging.
- [x] Verificar que `HEAD` es exactamente el commit fijado.
- [x] Verificar que el entrypoint existe y no es symlink fuera del checkout del plugin.
- [x] Activar solo despues de validar todos los plugins requeridos.
- [x] Guardar los plugins fuera de `$ZDOTDIR` y fuera del repositorio.

### 8.3 Actualizacion controlada

Replantear `zplugin-update`:

- Modo normal: reinstalar/validar exactamente los commits del lockfile.
- Modo de mantenimiento: consultar upstream y proponer nuevas revisiones sin activarlas automaticamente.
- Mostrar diff de commits y enlaces a changelogs antes de actualizar el lockfile.
- Permitir rollback conservando la revision previa.
- No llamar "paralela" a la actualizacion a menos que realmente implemente concurrencia con limites y manejo de errores.

### 8.4 Comportamiento offline

- [x] Una shell sin plugins instalados debe iniciar y mostrar, como maximo, un warning resumido.
- [x] No repetir ocho warnings en cada shell; almacenar/mostrar estado de forma no invasiva.
- [x] Las funciones base (`take`, `extract`, aliases seguros) deben cargar sin plugins.
- [x] Un plugin corrupto debe aislarse y no impedir cargar los demas, salvo que se marque obligatorio.
- [x] CI debe fallar si el codigo de inicio intenta ejecutar `git`, `curl` o `wget`.

## 9. Fase 4: correcciones de runtime

### 9.1 Parser robusto de `vdl`

Crear una funcion de error/uso y validar cada opcion antes de leer `$2`:

```zsh
case "$1" in
  -f|--format)
    (( $# >= 2 )) || { _vdl_usage_error "missing value for $1"; return 2; }
    # validar y consumir
    ;;
esac
```

Requisitos:

- [x] Falta de valor devuelve `2` inmediatamente y no produce salida repetitiva.
- [x] Opciones desconocidas devuelven `2`; no se ignoran.
- [x] Formatos permitidos: conjunto cerrado y documentado.
- [x] Codecs permitidos: conjunto cerrado con aliases normalizados.
- [x] Calidad: entero positivo dentro de un rango razonable.
- [x] `--output`: rechazar cadena vacia, NUL y rutas no deseadas segun politica documentada.
- [x] Permitir `--` para terminar opciones si se considera necesario.
- [x] Probar todas las permutaciones y aliases.

### 9.2 Contrato de calidad

Definir una sola semantica:

- **Recomendada:** `--quality N` es un maximo estricto. Si no existe formato `<= N`, fallar con mensaje explicito.
- Alternativa opt-in: `--allow-quality-fallback` permite superar el maximo y debe informar la resolucion elegida.

Eliminar todos los fallbacks sin `height<=N` cuando se solicito un maximo estricto. Aplicar el limite tanto a ramas con codec como sin codec.

Pruebas:

- [x] Formato exacto disponible.
- [x] Solo formatos menores disponibles.
- [x] Solo formatos mayores disponibles.
- [x] Combinacion codec + calidad.
- [x] Audio-only y formatos sin `height` no rompen el selector.
- [x] Metadata local de `yt-dlp`; sin red en PRs.

### 9.3 Estados de salida multimedia

Las correcciones recientes deben quedar protegidas por tests permanentes:

- `vconv`: `0` solo si todos los archivos solicitados tuvieron exito; documentar si el exito parcial devuelve `1`.
- `vaudio`: misma politica de batch que `vconv`.
- `vcut`: verificar existencia y tamano no cero de la salida ademas del codigo FFmpeg.
- `vgif`: verificar ambas fases, limpiar paleta mediante `trap` y validar salida no vacia.
- `adl`/`vdl`: no ocultar stderr completo; ofrecer `--quiet` si se necesita.
- Ninguna funcion debe sobrescribir una salida existente sin `--force` o confirmacion documentada.

### 9.4 `posh-theme` transaccional

Orden correcto:

1. Validar que `oh-my-posh` existe.
2. Validar el nombre del tema con una expresion conservadora, por ejemplo `^[A-Za-z0-9._-]+$`.
3. Resolver rutas y comprobar que permanecen dentro de los directorios permitidos.
4. Si se descarga, hacerlo a un archivo temporal con HTTPS y version/fuente fijada.
5. Validar JSON con `jq` o Python pasando la ruta como argumento, nunca interpolandola en codigo.
6. Aplicar la transformacion de `transient_prompt` a otro temporal.
7. Ejecutar `oh-my-posh init zsh --config <temporal>` y comprobar su codigo/salida.
8. Mover atomicamente el tema validado al cache/configuracion.
9. Escribir `current_theme` mediante temporal + `mv`.
10. Imprimir `[OK]` y aplicar el init a la shell actual.

Otros cambios:

- [x] Usar `$XDG_CACHE_HOME/oh-my-posh/themes`, no `$HOME/.cache` fijo.
- [x] No modificar los temas versionados cuando el modo es symlink.
- [x] Guardar variantes normalizadas en cache/state, no en el checkout.
- [x] Si no hay FZF o no hay temas, mostrar uso/estado coherente.
- [x] Verificar contenido exacto de `current_theme` en CI.
- [x] Un fallo no debe cambiar el tema activo anterior.

### 9.5 Aliases y portabilidad

- Detectar capacidades, no asumir GNU.
- Para `ls`, elegir entre `--color=auto`, `-G` o sin color mediante una prueba que no dependa de contenido.
- Para `grep`, considerar validos los codigos `0` y `1`; solo codigo `2` indica error de opcion.
- Aplicar el mismo patron a `diff`.
- Evaluar retirar aliases globales de `cp` y `mv`, o volverlos opt-in en `local.zsh`; cambiar semantica de utilidades basicas tiene alto impacto.
- Sustituir el `which` restante por `command -v`.
- Probar el fallback sin `eza`, `bat`, `fd`, GNU coreutils ni systemd.

### 9.6 Mensajes de helpers

Para `extract`:

```text
[OK] Extracted 2 archive(s).
[ERROR] Extracted 0 archive(s); 1 failed.
[WARN] Extracted 2 archive(s); 1 failed.
```

Definir y probar el codigo de salida de exito parcial. La recomendacion es devolver `1` si cualquier archivo fallo, aunque existan exitos.

### 9.7 Inicio de Zsh y rendimiento

- [x] Evitar ejecutar `infocmp` dos veces por shell; centralizar el fallback de `TERM`.
- [x] Evitar ejecutar `fzf --zsh` dos veces para detectar y luego cargar.
- [x] Inicializar integraciones externas solo en shells interactivas cuando corresponda.
- [x] Proteger llamadas que requieren TTY/ZLE.
- [x] Eliminar warnings `can't change option: zle` y `tput: command not found` en containers/no-TTY.
- [x] Medir cold/warm startup en una prueba informativa y establecer presupuesto inicial, por ejemplo `<=250 ms` con plugins instalados en el runner de referencia.
- [x] No convertir una medicion dependiente de hardware en gate hasta estabilizar el entorno.

### Criterios de aceptacion de la fase 4

- Todos los casos de argumentos invalidos terminan en menos de un segundo.
- Ningun fallo de tema cambia `current_theme` ni imprime `[OK]`.
- `--quality` nunca excede el maximo sin opt-in explicito.
- Los fallbacks de aliases pasan en GNU/Linux y macOS.
- Las rutas exitosas y fallidas de media tienen fixtures y aserciones sobre salidas/codigos.

## 10. Fase 5: suite automatizada completa

### 10.1 Contrato del sandbox

Cada prueba de integracion debe:

1. Crear un directorio con `mktemp -d`.
2. Definir `HOME`, los cuatro XDG y un `PATH` de herramientas simuladas.
3. Copiar o enlazar una copia de trabajo del repositorio, nunca usar el checkout real como destino.
4. Registrar todas las invocaciones externas en un log.
5. Ejecutar con timeout.
6. Validar codigo de salida, stdout, stderr, filesystem y permisos.
7. Eliminar el sandbox mediante `teardown` aun si falla la prueba.
8. Comprobar que `git status --porcelain` del checkout original sigue vacio.

Evitar que una prueba dependa de las herramientas instaladas en la maquina del desarrollador. Cuando se necesite una integracion real, marcarla y aislarla de las pruebas unitarias.

### 10.2 Casos del instalador

| Caso | Preparacion | Comando | Aserciones minimas |
|---|---|---|---|
| Copia limpia | HOME vacio | `install --mode copy --no-deps --yes` | Codigo 0, archivos regulares, sintaxis valida, sin backups espurios |
| Symlink limpio | HOME vacio | `install --mode symlink --no-deps --yes` | Codigo 0, enlaces al repo de prueba, repo sin cambios |
| Rerun copia | Copia gestionada | Repetir copia | Contenido estable, `local.zsh` preservado, politica de backup cumplida |
| Rerun symlink | Symlink correcto | Repetir symlink | No-op, sin backups, permisos del repo intactos |
| Copia -> symlink | Copia + local | Instalar symlink | Backup recuperable, local activo, enlaces correctos |
| Symlink -> copia | Symlink correcto | Instalar copia | Enlace retirado, archivos materializados, codigo 0 |
| Directorio externo | Configuracion no gestionada | Ambos modos | Snapshot completo antes de reemplazo |
| Symlink externo | Enlace a directorio externo | Ambos modos | Destino externo byte-identico, enlace original respaldado sin dereferencia |
| `.zshenv` externo | Enlace a archivo externo | Ambos modos | Destino externo intacto, enlace original restaurable |
| Symlink roto | Enlace sin destino | Ambos modos | Metadata respaldada, instalacion exitosa |
| Archivo en ZDOTDIR | Archivo regular | Ambos modos | Backup + reemplazo controlado o error documentado |
| FIFO/socket | Tipo inesperado | Ambos modos | Abortar sin leer/borrar el objeto |
| XDG personalizado | Cuatro XDG no default | Ambos modos | Todo se instala/carga desde rutas personalizadas |
| HOME con espacios | Ruta temporal con espacios | Ambos modos | Sin word splitting ni rutas truncadas |
| Script por symlink | `install.sh` enlazado | Ejecutar enlace | Recursos resueltos desde repo real |
| Instalaciones simultaneas | Dos procesos sobre el mismo HOME | Ambos modos | Solo uno adquiere lock; el otro no cambia estado |
| Backup colision | `date` fijo | Tres reruns | Tres IDs unicos, ningun snapshot sobrescrito |
| Backup falla | `cp`/filesystem simulado falla | Instalar | Destino original intacto, codigo no cero |
| Activacion falla | `mv` simulado falla | Instalar | Original recuperable, staging limpiado |
| Senal durante commit | Inyectar `INT`/`TERM` entre destinos | Instalar | Rollback completo o instrucciones exactas sin falso exito |
| Opcion desconocida | HOME vacio | `--no-depz` | Codigo 2, cero llamadas de red/paquetes |
| Dependencias omitidas | HOME vacio | `--no-deps` | Cero `sudo`, red o package manager |
| Rechazo interactivo | Entrada `n` | Instalacion interactiva | Igual a `--no-deps` |
| Fallo de paquete | Gestor devuelve 1 | Instalacion completa | Codigo no cero si falta requerido; resumen fiel |
| Sin sudo | Usuario no root | Instalacion completa | Error accionable o fallback user-local documentado |
| Dry run | Estado complejo | `--dry-run` | Cero cambios; plan coincide con operacion real |
| Root sync | Root destino simulado | `--sync-root` | Backups, ownership logico, no secretos del usuario |
| Restore | Backup de cada tipo | `--restore <id>` | Se reconstruye tipo, contenido y enlace original |

### 10.3 Casos de entorno e inicio

- [x] Preservar XDG predefinido.
- [x] Aplicar defaults cuando XDG esta ausente.
- [x] Cargar `ZDOTDIR` correcto en shell login, interactiva y no interactiva.
- [x] No establecer `GPG_TTY="not a tty"`.
- [x] No duplicar `PATH` despues de cargar `.zshenv` varias veces.
- [x] Incluir `PNPM_HOME` correcto solo cuando corresponde.
- [x] Iniciar sin `eza`, `bat`, `fd`, `fzf`, Atuin y Oh My Posh.
- [x] Iniciar sin red y sin plugins instalados.
- [x] No invocar `git`, `curl`, `wget` durante startup.
- [x] No emitir errores ZLE/tput cuando no hay TTY.
- [x] Crear directorios de history/cache necesarios o degradar con mensaje claro.

### 10.4 Casos de helpers y multimedia

#### `take`

- Cero argumentos.
- Una ruta y multiples rutas.
- Ruta con espacios.
- Fallo de `mkdir` no cambia directorio.
- Se posiciona en la ultima ruta documentada.

#### `extract`

- Sin argumentos.
- Archivo inexistente.
- Archivo corrupto.
- Formato desconocido sin fallback.
- Un archivo valido por formato soportado disponible en CI.
- Batch completamente exitoso.
- Batch parcialmente fallido.
- Nombres con espacios y guiones iniciales.
- Mensajes y codigos coherentes con el resumen.

#### `vconv`, `vaudio`, `vcut`, `vgif`

- Dependencia ausente.
- Input inexistente/corrupto.
- Output preexistente.
- Nombre con espacios.
- Batch exitoso, parcial y completamente fallido.
- FFmpeg falla en cada etapa simulada.
- Camino real con clip sintetico pequeno.
- Validar salida con `ffprobe`, no solo existencia.

#### `vdl` y `adl`

- Cada opcion corta y larga.
- Cada opcion sin valor.
- Opcion desconocida.
- Codec invalido y valido.
- Calidad invalida, exacta, menor disponible y ninguna compatible.
- Playlist activada/desactivada.
- Output personalizado.
- URL vacia y URL con query de Twitter/X.
- Fallo directo seguido de fallback simulado.
- Ninguna prueba obligatoria de PR debe contactar servicios externos.

### 10.5 Casos de temas

- Tema incluido valido.
- Tema en cache XDG.
- Seleccion interactiva simulada con FZF.
- Duplicados entre local/cache.
- Nombre con traversal (`../`), slash, comillas o salto de linea.
- JSON invalido.
- Descarga 404 o parcial.
- Oh My Posh ausente.
- Oh My Posh devuelve error.
- `current_theme` previo se conserva ante cualquier fallo.
- Exito persiste exactamente el nombre esperado.
- Modo symlink no modifica archivos del checkout.

### 10.6 Casos de plugins

- Todos los commits del lockfile estan disponibles y coinciden.
- Un plugin ausente no provoca red durante startup.
- Instalacion explicita offline falla limpiamente.
- Checkout en commit distinto se detecta.
- Entrypoint ausente o symlink externo se rechaza.
- Actualizacion propone cambio sin alterar lockfile automaticamente.
- Rollback carga la revision previa.

### 10.7 Pruebas interactivas

Automatizar hasta donde sea estable con `zpty`:

- Registro y ejecucion de `magic-sudo` en buffers vacios/no vacios.
- Bindings de Atuin presentes/ausentes.
- Fallback de history substring.
- `_fzf_file_no_hidden` escapa espacios, comillas, globbing, `$()` y `;`.
- Widgets solo se registran cuando ZLE esta disponible.
- Vi mode y autopair pueden quedar como prueba PTY focalizada y checklist manual visual.

### 10.8 Tests de seguridad estatica

Fallar CI si se introducen patrones prohibidos en rutas ejecutables:

```text
curl ... | sh
curl ... | bash
/releases/latest/
git clone sin commit/lock posterior
rm -rf con destino no validado
chmod -R sobre una variable que puede ser symlink
```

La deteccion estatica es una defensa adicional; no reemplaza las pruebas de comportamiento.

## 11. Fase 6: CI reproducible y representativa

### 11.1 Workflows propuestos

```text
.github/workflows/
|-- lint.yml
|-- unit.yml
|-- installer-linux.yml
|-- macos.yml
|-- interactive.yml
`-- external-smoke.yml
```

#### `lint.yml`

- `shellcheck` para Bash con exclusiones justificadas por linea, no globales amplias.
- `shfmt -d` para Bash si se adopta como formato oficial.
- `zsh -n` sobre todos los `.zsh`, `.zshrc`, `.zshenv` y ejemplos.
- Validacion JSON de temas y lockfiles.
- `actionlint` para workflows.
- Markdown lint con configuracion versionada.
- Busqueda de patrones de seguridad prohibidos.

#### `unit.yml`

- Bats y pruebas Zsh deterministas.
- Sin red.
- Timeout corto por test y por job.
- Cobertura de argumentos, funciones, estados y stubs.

#### `installer-linux.yml`

- Matriz de familias realmente soportadas.
- Probar como usuario normal creado dentro del container.
- Submatriz reducida para root sync.
- Ejecutar copia limpia, symlink limpio, reruns y ambas transiciones en HOME separados.
- Probar `--no-deps` en todos; probar gestores reales en una seleccion representativa.

#### `macos.yml`

- Runner macOS soportado.
- Instalacion user-local sin asumir GNU coreutils.
- Fallbacks de `ls`, `grep`, `diff`, `mktemp`, `sed` y `readlink`.
- Copia, symlink, transiciones y startup.

#### `interactive.yml`

- Linux con pseudo-TTY.
- Widgets y bindings estables.
- Separado para que fallos de terminal sean diagnosticables.

#### `external-smoke.yml`

- Solo `schedule` y ejecucion manual.
- Pruebas minimas contra endpoints reales de yt-dlp/temas.
- No bloquear PRs por cambios o outages de terceros.
- Alertar cuando una integracion externa lleva varios fallos consecutivos.

### 11.2 Matriz de compatibilidad

Definir tres niveles:

| Nivel | Significado | Requisito |
|---|---|---|
| Soportado | Se espera funcionamiento completo | Job CI actual, usuario normal y flujos principales |
| Verificado parcialmente | Startup/config basica confirmada | Smoke test y limitaciones documentadas |
| Best effort | Codigo contiene adaptador, sin garantia continua | Sin badge de soporte; instrucciones comunitarias |

Acciones:

- [x] Sustituir Fedora 40/41 y cualquier distro EOL por versiones soportadas en el momento de implementar.
- [x] Incluir Gentoo realmente o retirarlo del nombre/workflow/README.
- [x] Incluir macOS realmente o degradar su declaracion a best effort.
- [x] Corregir Debian Testing vs Debian 11.
- [x] Revisar la matriz trimestralmente o con una tarea automatizada.
- [x] No usar palabras `Latest` si la etiqueta exacta no esta en el workflow.

### 11.3 Fijacion y permisos

- [x] Fijar Actions a SHA completa y documentar la version humana en comentario.
- [x] Fijar imagenes de container por digest cuando sea viable.
- [x] Fijar versiones de herramientas de lint/test.
- [x] Declarar `permissions: contents: read` a nivel workflow.
- [x] Anadir `timeout-minutes` a todos los jobs.
- [x] Usar `concurrency` para cancelar runs obsoletos de la misma rama.
- [x] No exponer secretos a tests de pull requests.
- [x] Separar caches por OS, version y hash de lockfile.

### 11.4 Calidad de aserciones

No aceptar comprobaciones que solo confirmen que un archivo existe.

Ejemplos:

- Tema: validar contenido de `current_theme`, JSON e init de Oh My Posh.
- Symlink: validar destino exacto y que el checkout no cambio.
- Helper: validar resultado y codigo, no solo imprimir un texto posterior.
- Instalacion: validar lista de dependencias y resumen; buscar `[ERROR]` inesperados en logs.
- Startup: validar ausencia de stderr inesperado en modo correspondiente.

### 11.5 Politica de logs

- No redirigir errores de operaciones importantes a `/dev/null` en CI.
- Guardar logs de instalador por etapa.
- Subir como artifact los logs y manifiestos de backup solo cuando falla un job, sin secretos.
- Mantener una allowlist pequena para warnings externos inevitables.
- Hacer fallar jobs por warnings propios conocidos como `wget: command not found`, `can't change option: zle` o falsos `[OK]`.

## 12. Fase 7: documentacion y experiencia de mantenimiento

### 12.1 README

Actualizar [README.md](./README.md) con:

- Tabla de compatibilidad real y nivel de soporte.
- Requisitos minimos y opcionales.
- Diferencias entre copia y symlink.
- Rutas XDG efectivas.
- `--no-deps`, `--dry-run`, modo explicito y opciones de privilegios.
- Que operaciones usan red.
- Donde se guarda configuracion privada.
- Donde se guardan plugins, temas descargados, cache, state y backups.
- Como listar y restaurar backups.
- Politica de versiones/checksums.
- Limitaciones de funciones externas y pruebas programadas.
- Procedimiento de migracion desde la estructura actual.

### 12.2 Guia de seguridad

Crear `SECURITY.md` o una seccion dedicada que explique:

- Modelo de amenazas del instalador.
- Fuentes de binarios y plugins.
- Verificacion de lockfiles/checksums.
- Como reportar una vulnerabilidad sin abrir un issue publico.
- Alcance de APIs de terceros usadas por fallbacks multimedia.
- Que datos/URLs pueden enviarse a servicios externos.

### 12.3 Guia de contribucion

Crear `CONTRIBUTING.md` con:

- Comandos de setup, lint, unit e integracion.
- Convenciones Bash/Zsh.
- Regla de no red durante startup/tests de PR.
- Como actualizar dependencias/plugins fijados.
- Como anadir una distro sin inflar afirmaciones de soporte.
- Checklist de PR y requisito de pruebas negativas.

### 12.4 Escenarios de prueba

Reestructurar [TEST_SCENARIOS.md](./TEST_SCENARIOS.md):

- Marcar cada escenario como `Automated`, `Manual` o `External scheduled`.
- Enlazar la prueba automatizada que lo cubre.
- Definir fixtures, prerequisitos, setup, cleanup y resultado objetivo.
- Sustituir criterios subjetivos (`unpixelated`) por medidas verificables cuando sea posible.
- No usar URLs placeholder como si fueran una prueba ejecutable.
- Corregir la descripcion de actualizacion paralela de plugins.
- Separar pruebas visuales de las funcionales.

### 12.5 Registro de migracion

Documentar cambios incompatibles:

- Nuevo modelo de symlinks por archivo que mantiene `local.zsh` como archivo local regular.
- Nueva ubicacion de plugins y temas descargados.
- Semantica estricta de `vdl --quality`.
- Opciones del instalador renombradas/deprecadas.
- Restauracion y formato de backups.
- Eliminacion de aliases invasivos si se decide aplicarla.

## 13. Secuencia recomendada de entregas

No implementar todo en un unico PR. Secuencia sugerida:

| PR | Alcance | Dependencias | Riesgo |
|---|---|---|---|
| `01-test-harness` | Bats, sandbox, stubs y reproducciones rojas P0 | Ninguna | Bajo; solo infraestructura |
| `02-installer-paths-cli` | Parser estricto, rutas XDG, resolucion de script, dry-run | PR 01 | Medio |
| `03-installer-backup-state` | Clasificador, backups unicos, restore, guards | PR 02 | Alto; revisar exhaustivamente |
| `04-installer-deploy` | Staging, activacion, transiciones, local externo | PR 03 | Alto |
| `05-root-sync` | Reutilizar pipeline seguro para root | PR 04 | Alto y acotado |
| `06-dependency-security` | Preflight, errores, releases/checksums, privilegios | PR 01-04 | Alto |
| `07-plugin-locking` | Lockfile, instalacion explicita, startup offline | PR 06 | Medio-alto |
| `08-vdl-runtime` | Parser, calidad estricta, tests de selectores | PR 01 | Medio |
| `09-theme-runtime` | Tema transaccional, XDG cache, validacion | PR 01 | Medio |
| `10-portability-ux` | Aliases, mensajes, no-TTY, rendimiento | PR 01 | Medio-bajo |
| `11-ci-hardening` | Nuevos workflows, usuario normal, pins, matrix real | PRs funcionales | Medio |
| `12-documentation` | README, security, contributing, escenarios y migracion | Todos | Bajo |

Cada PR debe:

- Contener las pruebas rojas relevantes antes o junto a la correccion.
- Tener alcance unico y rollback comprensible.
- Mantener compatibilidad o documentar explicitamente la migracion.
- Actualizar este plan marcando IDs cerrados y enlaces a commits/PRs.
- No mezclar actualizaciones masivas de dependencias con logica del instalador.

## 14. Dependencias entre trabajos

```text
Test harness
|-- Installer paths/CLI
|   `-- Backup state machine
|       `-- Atomic deployment/transitions
|           `-- Root sync
|-- Runtime vdl
|-- Runtime themes
|-- Runtime portability
`-- Plugin/dependency security
    `-- CI hardening
        `-- Documentation and release
```

Bloqueos importantes:

- No migrar el modo symlink legacy sin tener preservacion de `local.zsh` y restore probados.
- No eliminar cloning en startup sin proporcionar instalacion explicita de plugins.
- No anunciar soporte nuevo sin job de usuario normal.
- No activar `set -u` hasta que el instalador tenga parser y defaults consistentes.
- No volver obligatoria una prueba externa dependiente de servicios de terceros.

## 15. Estrategia de rollback

### Instalador

- Mantener el backup anterior hasta que una nueva shell verificada inicie correctamente.
- Si falla la activacion, restaurar el destino anterior automaticamente cuando sea seguro.
- Nunca borrar el backup como parte del mismo proceso de instalacion.
- Permitir rollback manual aun si la version nueva del instalador no ejecuta.

### Plugins y dependencias

- Conservar el lockfile previo en Git.
- Mantener una revision anterior instalada hasta validar la nueva.
- Cambiar un lockfile debe ser suficiente para volver a la version conocida.

### Runtime

- Mantener aliases/opciones antiguas durante una ventana de deprecacion cuando cambie UX publica.
- Anadir warnings de migracion sin romper shells no interactivas.

## 16. Riesgos de ejecucion del plan

| Riesgo | Mitigacion |
|---|---|
| El rediseno del instalador introduce perdida de datos | Pruebas rojas primero, staging, backups fuera del destino, revision separada |
| La matriz CI se vuelve demasiado lenta | Separar unit, distro smoke, PTY y external scheduled; usar submatrices focalizadas |
| Pins/checksums aumentan mantenimiento | Bot/issue de actualizacion, PRs de lockfile separados, revision periodica |
| Migrar el symlink de directorio legacy pierde archivos locales | Manifiesto por archivo, preservacion previa, backup y prueba de ambas transiciones |
| Plugins fijados quedan obsoletos | Cadencia de actualizacion y pruebas programadas, sin actualizar durante startup |
| macOS diverge de GNU/Linux | Helpers de capacidades y job nativo macOS |
| Tests de terminal son inestables | Aislar PTY, minimizar aserciones visuales, mantener checklist manual para geometria |

## 17. Comandos de desarrollo propuestos

Proporcionar una interfaz estable mediante `Makefile` o scripts equivalentes:

```bash
make lint                 # Analisis estatico, sintaxis, JSON, workflows, Markdown
make test                 # Suite determinista sin red
make test-installer       # Integracion en HOME temporal
make test-runtime         # Helpers, media, temas, entorno, plugins
make test-interactive     # zpty/TTY
make test-external        # Opt-in; usa servicios reales
make verify               # lint + test + instalacion limpia y git status
```

`make verify` debe ser el comando local equivalente al gate obligatorio de PR.

## 18. Definicion de terminado por area

### Instalador

- [x] Todos los tipos de destino y transiciones estan probados.
- [x] Backups son unicos y restaurables; archivos/directorios se materializan y symlinks se preservan sin dereferenciar.
- [x] No sigue symlinks externos al desplegar.
- [x] Respeta XDG personalizado.
- [x] No modifica el checkout en ningun modo.
- [x] Errores obligatorios producen codigo no cero y resumen fiel.
- [x] Root usa el mismo pipeline seguro.

### Seguridad

- [x] No hay ejecucion remota por pipe.
- [x] Binarios y plugins estan fijados y verificados.
- [x] Startup no usa red.
- [x] Escrituras privilegiadas son explicitas.
- [x] Hay politica de actualizacion y rollback.

### Runtime

- [x] Argumentos invalidos no bloquean ni generan salida infinita.
- [x] Calidad maxima es estricta o se documenta el opt-in de fallback.
- [x] Temas solo se persisten despues de validacion completa.
- [x] Mensajes y codigos de helpers/media son coherentes.
- [x] Fallbacks funcionan en GNU/Linux y macOS.

### Pruebas y CI

- [x] P0/P1 tienen pruebas automatizadas negativas y positivas.
- [x] CI ejecuta como usuario normal.
- [x] Las plataformas soportadas tienen jobs reales.
- [x] Actions, imagenes y herramientas estan fijadas.
- [x] No se toleran errores propios conocidos en logs.
- [x] Pruebas externas estan separadas de PRs.

### Documentacion

- [x] Compatibilidad declarada coincide con CI.
- [x] Modos, XDG, backups, restore, red y seguridad estan documentados.
- [x] La migracion de configuracion privada esta explicada.
- [x] Los escenarios indican su cobertura automatizada/manual.

## 19. Checklist de release posterior a la remediacion

- [x] Ejecutar `make verify` en un checkout limpio.
- [x] Ejecutar instalacion copia y symlink en HOME nuevos.
- [x] Ejecutar ambas transiciones y un restore real.
- [x] Confirmar que `local.zsh` permanece activo y fuera del checkout.
- [x] Probar XDG personalizado.
- [x] Probar usuario normal sin sudo y con sudo.
- [x] Probar root sync en entorno desechable.
- [x] Verificar checksums y commits de todos los lockfiles.
- [x] Confirmar startup offline y sin plugins instalados.
- [x] Confirmar ausencia de cambios con `git status --porcelain`.
- [x] Revisar logs CI completos, no solo badges.
- [x] Actualizar tabla de compatibilidad y notas de migracion.
- [x] Etiquetar la version solo despues de que todos los jobs obligatorios esten verdes.

## 20. Meta de calidad

La meta razonable despues de cerrar todos los P0/P1 es alcanzar al menos:

| Area | Meta |
|---|---:|
| Arquitectura y legibilidad | 9/10 |
| Runtime y utilidades | 9/10 |
| Instalador y reversibilidad | 9/10 |
| Seguridad y reproducibilidad | 8.5/10 |
| Portabilidad | 8.5/10 |
| CI y pruebas | 9/10 |
| Documentacion | 9/10 |

La nota no debe considerarse alcanzada por cantidad de cambios, sino por evidencia: tests negativos, recuperacion comprobada, ausencia de red al iniciar, dependencias verificadas y compatibilidad respaldada por CI.
