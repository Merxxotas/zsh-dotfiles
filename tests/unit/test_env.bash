#!/usr/bin/env bash
# =========================================================
# tests/unit/test_env.bash - Unit tests for .zshenv
# =========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running unit tests for .zshenv..."

# Test 1: Custom XDG variables are preserved
(
  export XDG_CONFIG_HOME="/custom/config"
  export XDG_CACHE_HOME="/custom/cache"
  export XDG_DATA_HOME="/custom/data"
  export XDG_STATE_HOME="/custom/state"

  zsh -c "source '$SCRIPT_DIR/.config/zsh/.zshenv'; [ \"\$XDG_CONFIG_HOME\" = '/custom/config' ]"
  assert_success $? "XDG_CONFIG_HOME should be preserved"
)

# Test 2: PATH is deduplicated across multiple sources
(
  export PATH="/bin:/usr/bin"
  zsh -c "
    source '$SCRIPT_DIR/.config/zsh/.zshenv'
    source '$SCRIPT_DIR/.config/zsh/.zshenv'
    count=\$(echo \"\$PATH\" | tr ':' '\n' | grep -c '\.cargo/bin')
    [ \"\$count\" -eq 1 ]
  "
  assert_success $? "PATH should not have duplicate cargo entries after multiple sources"
)

# Test 3: GPG_TTY is not set to 'not a tty' in non-interactive script
(
  zsh -c "
    source '$SCRIPT_DIR/.config/zsh/.zshenv'
    [ \"\$GPG_TTY\" != 'not a tty' ]
  "
  assert_success $? "GPG_TTY should not be set to 'not a tty' in non-interactive shell"
)

teardown_sandbox
echo ".zshenv tests passed successfully!"
