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

# Test 4: PNPM directories ($PNPM_HOME/bin and $PNPM_HOME) are in PATH
(
  zsh -c "
    source '$SCRIPT_DIR/.config/zsh/.zshenv'
    echo \"\$PATH\" | grep -q \"\$PNPM_HOME/bin\" && echo \"\$PATH\" | grep -q \"\$PNPM_HOME\"
  "
  assert_success $? "PNPM_HOME/bin and PNPM_HOME should be present in PATH"
)

# Test 5: npm-global bin directory is in PATH
(
  zsh -c "
    source '$SCRIPT_DIR/.config/zsh/.zshenv'
    echo \"\$PATH\" | grep -q '\.npm-global/bin'
  "
  assert_success $? "npm-global/bin should be present in PATH"
)

# Test 6: zsh-abbr and zsh-job-queue temp dirs are isolated per user
(
  runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
  out="$(zsh -c "source '$SCRIPT_DIR/.config/zsh/.zshenv'; print -r -- \"\$JOB_QUEUE_TMPDIR|\$ABBR_TMPDIR\"")"
  assert_equal "$out" "${runtime_dir}/zsh-job-queue-$(id -u)|${runtime_dir}/zsh-abbr-$(id -u)" \
    "JOB_QUEUE_TMPDIR and ABBR_TMPDIR should be scoped to the current UID"
)

# Test 7: root fallback sources $ZDOTDIR/.zshenv (guards against silent drift)
(
  mkdir -p "$HOME/.config/zsh"
  printf 'export ZSHENV_MARKER=sourced\n' > "$HOME/.config/zsh/.zshenv"
  XDG_CONFIG_HOME= zsh -c "source '$SCRIPT_DIR/.zshenv'; [ \"\$ZSHENV_MARKER\" = sourced ]"
  assert_success $? "root ~/.zshenv should source \$ZDOTDIR/.zshenv when present"
)

teardown_sandbox
echo ".zshenv tests passed successfully!"
