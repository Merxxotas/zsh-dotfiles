#!/usr/bin/env bash
# =========================================================
# tests/unit/test_prompt.bash - Unit tests for prompt.zsh
# =========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running unit tests for prompt.zsh..."

# Test 1: posh-theme with directory traversal name is rejected
zsh -c "source '$SCRIPT_DIR/.config/zsh/prompt.zsh'; posh-theme '../../etc/passwd'" >/dev/null 2>&1
assert_failure $? 1 "posh-theme should reject traversal names"

# Test 2: posh-theme with special characters is rejected
zsh -c "source '$SCRIPT_DIR/.config/zsh/prompt.zsh'; posh-theme 'theme; rm -rf /'" >/dev/null 2>&1
assert_failure $? 1 "posh-theme should reject special script characters"

# Test 3: mock oh-my-posh and test clean-detailed activation
mock_command "oh-my-posh" '
if [ "$1" = "init" ]; then
  echo "# mocked oh-my-posh init"
  exit 0
fi
exit 0
'

zsh -c "source '$SCRIPT_DIR/.config/zsh/prompt.zsh'; posh-theme clean-detailed" >/dev/null 2>&1
assert_success $? "posh-theme clean-detailed should succeed"
assert_file_contains "$HOME/.local/state/zsh/current_theme" "clean-detailed"

teardown_sandbox
echo "prompt.zsh tests passed successfully!"
