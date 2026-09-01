#!/usr/bin/env bash
# ==============================================================================
# tests/helpers/sandbox.bash - Sandbox Environment for Isolation Testing
# ==============================================================================

ORIGINAL_HOME="$HOME"
ORIGINAL_PATH="$PATH"
ORIGINAL_XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-}"
ORIGINAL_XDG_CACHE_HOME="${XDG_CACHE_HOME:-}"
ORIGINAL_XDG_DATA_HOME="${XDG_DATA_HOME:-}"
ORIGINAL_XDG_STATE_HOME="${XDG_STATE_HOME:-}"
ORIGINAL_ZDOTDIR="${ZDOTDIR:-}"

SANDBOX_DIR=""

setup_sandbox() {
  SANDBOX_DIR="$(mktemp -d -t zsh-dotfiles-test.XXXXXX)"
  export HOME="$SANDBOX_DIR/home"
  export XDG_CONFIG_HOME="$HOME/.config"
  export XDG_CACHE_HOME="$HOME/.cache"
  export XDG_DATA_HOME="$HOME/.local/share"
  export XDG_STATE_HOME="$HOME/.local/state"
  export ZDOTDIR=""

  mkdir -p "$HOME" "$HOME/.config" "$HOME/.cache" "$HOME/.local/share" "$HOME/.local/state" "$HOME/.local/bin"
  mkdir -p "$SANDBOX_DIR/mock_bin"

  export PATH="$SANDBOX_DIR/mock_bin:$HOME/.local/bin:$ORIGINAL_PATH"
}

teardown_sandbox() {
  if [ -n "$SANDBOX_DIR" ] && [ -d "$SANDBOX_DIR" ]; then
    rm -rf "$SANDBOX_DIR"
  fi
  export HOME="$ORIGINAL_HOME"
  export PATH="$ORIGINAL_PATH"
  export XDG_CONFIG_HOME="$ORIGINAL_XDG_CONFIG_HOME"
  export XDG_CACHE_HOME="$ORIGINAL_XDG_CACHE_HOME"
  export XDG_DATA_HOME="$ORIGINAL_XDG_DATA_HOME"
  export XDG_STATE_HOME="$ORIGINAL_XDG_STATE_HOME"
  export ZDOTDIR="$ORIGINAL_ZDOTDIR"
}

mock_command() {
  local cmd_name="$1"
  local cmd_body="$2"
  local mock_path="$SANDBOX_DIR/mock_bin/$cmd_name"

  cat <<EOF > "$mock_path"
#!/usr/bin/env bash
$cmd_body
EOF
  chmod +x "$mock_path"
}
