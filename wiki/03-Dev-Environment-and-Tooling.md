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
