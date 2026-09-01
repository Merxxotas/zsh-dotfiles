#!/usr/bin/env bash
# =========================================================
# tests/unit/test_plugins.bash - Unit tests for plugins.zsh
# =========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running unit tests for plugins.zsh..."

# Test 1: Sourcing plugins.zsh when plugins are missing does NOT execute git
mock_command "git" '
echo "FATAL: git called unexpectedly during shell startup!" >&2
exit 99
'

(
  # Non-interactive load should be clean and not invoke git
  zsh -c "source '$SCRIPT_DIR/.config/zsh/plugins.zsh'"
)
assert_success $? "plugins.zsh should not invoke git during startup"

# Test 2: plugins.lock exists and contains valid 40-char commit SHAs
assert_file_exists "$SCRIPT_DIR/plugins.lock" "plugins.lock should exist"

line_count=0
while IFS=$'\t' read -r name repo commit entrypoint; do
  [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
  line_count=$((line_count + 1))
  # Verify 40-char hexadecimal SHA
  if [[ ! "$commit" =~ ^[0-9a-f]{40}$ ]]; then
    echo "  [FAIL] Plugin '$name' has invalid commit SHA: '$commit'" >&2
    exit 1
  fi
done < "$SCRIPT_DIR/plugins.lock"

assert_equal "$line_count" "8" "plugins.lock should track 8 plugins"

teardown_sandbox
echo "plugins.zsh tests passed successfully!"
