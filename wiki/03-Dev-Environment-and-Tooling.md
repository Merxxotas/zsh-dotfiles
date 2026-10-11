# 03 - Dev Environment and Tooling

`dev-env.zsh` and `.zshenv` configure a modern, universal developer environment with zero-latency startup.

---

## PNPM (v10 / v11+) Configuration

In modern pnpm (versions 10 and 11+), global binaries are placed in `$PNPM_HOME/bin` rather than directly in `$PNPM_HOME`.

### PATH Resolution in `.zshenv`:
```zsh
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
path=(
  "$PNPM_HOME/bin"
  "$PNPM_HOME"
  $path
)
```

Both paths are injected into the array. This prevents `[ERROR] The configured global bin directory ... is not in PATH` and guarantees that global packages (such as CLI agents, tooling, and linters) are immediately callable in any subshell.

---

## Node.js & NVM Zero-Latency Lazy Loading

Traditional NVM adds between 300ms and 1500ms to shell startup time. In this architecture, NVM is completely lazy-loaded:

```zsh
if [ -d "$HOME/.nvm" ] || [ -f "/usr/share/nvm/init-nvm.sh" ]; then
  export NVM_DIR="$HOME/.nvm"
  _load_nvm() {
    unset -f nvm node npm npx yarn pnpm bun 2>/dev/null
    if [ -f "/usr/share/nvm/init-nvm.sh" ]; then
      source /usr/share/nvm/init-nvm.sh
    elif [ -s "$NVM_DIR/nvm.sh" ]; then
      \. "$NVM_DIR/nvm.sh"
    fi
  }
  nvm()  { _load_nvm; nvm "$@"; }
  node() { _load_nvm; node "$@"; }
  npm()  { _load_nvm; npm "$@"; }
  npx()  { _load_nvm; npx "$@"; }
fi
```
The overhead on shell spawn is **0ms**. NVM initializes transparently the first time `node`, `npm`, `npx`, or `nvm` is executed.

---

## Bun Runtime

Bun is discovered in `$HOME/.bun/bin` and prepended to `$PATH`.

---

## Rust & Cargo

If `$HOME/.cargo/env` exists, it is sourced, and `$HOME/.cargo/bin` is added to `$PATH`. Deduplication ensures no redundant PATH entries occur upon multiple shell invocations.

---

## Command Auto-Correction: `pay-respects`

Replaces legacy `thefuck` with a high-performance Rust-based auto-correction utility:
```zsh
if command -v pay-respects >/dev/null 2>&1; then
  eval "$(pay-respects zsh --alias fuck --nocnf)"
elif command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi
```
* Aliased to `fuck`.
* Configured with `--nocnf` to disable command-not-found hooks that interfere with interactive completions.

---

## IntelliShell Integration

Integrates AI-assisted command bookmarks, semantic history, and keyboard shortcuts:
```zsh
export INTELLI_HOME="$HOME/.local/share/intelli-shell"
export PATH="$INTELLI_HOME/bin:$PATH"
if command -v intelli-shell >/dev/null 2>&1; then
  eval "$(intelli-shell init zsh)"
fi
```

---

## Atuin Shell History

Full integration with Atuin SQLite-backed shell history sync:
```zsh
if [ -f "$HOME/.atuin/bin/env" ]; then
  . "$HOME/.atuin/bin/env"
fi
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi
```
Triggered interactively via `Ctrl + R`.

---

## User-Space Global NPM (`~/.npm-global/bin`)

To avoid requiring `sudo` for global npm packages, users can configure `npm config set prefix ~/.npm-global`.
The `$HOME/.npm-global/bin` directory is automatically included in `.zshenv`'s consolidated universal PATH:
```zsh
path=(
  "$HOME/.local/bin"
  "$HOME/.cargo/bin"
  "$HOME/.atuin/bin"
  "$HOME/.npm-global/bin"
  $path
)
```
This guarantees user-space npm CLI tools (such as OpenCLI, Codegraph, and mcporter) are immediately accessible across all interactive and non-interactive shells.

---

## AI Agent & Workspace Safety Guards (Gentle Shell & Git)

AI coding harnesses and agents (such as `gentle-shell` and `gentle-ai`) require a distinct Git workspace to calculate review budgets and project authority. When invoked directly inside `$HOME` (`~`), upstream review routines may automatically initialize a Git repository (`git init $PWD`), unintentionally tracking the user's entire home directory.

To prevent this issue, `dev-env.zsh` includes defensive shell wrappers:

### 1. `gentle-shell` & `gentle-ai` Guards
Intercepts invocation when `$PWD == $HOME`:
```zsh
gentle-shell() {
  if [[ -z "${GENTLE_ALLOW_HOME:-}" && "$PWD" == "$HOME" ]]; then
    echo "[ERROR] Cannot run gentle-shell directly in \$HOME (~)." >&2
    echo "[INFO] Navigate to a project workspace directory first (e.g. cd ~/Projects/<repo>)." >&2
    echo "[HINT] Set GENTLE_ALLOW_HOME=1 to override if intentional." >&2
    return 1
  fi
  command gentle-shell "$@"
}
```
* **Safe Subcommands**: `gentle-ai` allows informational commands (`doctor`, `version`, `help`, `update`, `telemetry`) from any directory, while blocking mutating or review actions (`review`, `install`, `sync`) within `$HOME`.
* **Explicit Override**: Set `GENTLE_ALLOW_HOME=1` to bypass the guard when explicitly needed.

### 2. Git Home Initialization Guard
Intercepts bare or explicit `git init` calls targeting `$HOME`:
```zsh
git() {
  if [[ "$1" == "init" && -z "${GIT_ALLOW_HOME_INIT:-}" ]]; then
    local target="${2:-$PWD}"
    if [[ "$target" == "." ]]; then target="$PWD"; fi
    if [[ "$target" == "$HOME" || ( "$PWD" == "$HOME" && $# -le 1 ) || "$target" == "~" ]]; then
      echo "[ERROR] Refusing to initialize a Git repository directly in \$HOME (~)." >&2
      echo "[INFO] Navigate to or specify a project workspace directory first." >&2
      echo "[HINT] Set GIT_ALLOW_HOME_INIT=1 to override if intentional." >&2
      return 1
    fi
  fi
  command git "$@"
}
```
* **Explicit Override**: `GIT_ALLOW_HOME_INIT=1 git init` allows intentional repository creation in home if needed.

