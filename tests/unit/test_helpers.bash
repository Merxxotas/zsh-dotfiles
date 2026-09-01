#!/usr/bin/env bash
# ==============================================================================
# tests/unit/test_helpers.bash - Unit tests for helpers.zsh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running unit tests for helpers.zsh..."

# Test 1: take with no arguments returns error
zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; take" >/dev/null 2>&1
assert_failure $? 1 "take with no arguments should return exit code 1"

# Test 2: take with valid path creates directory
test_dir="$SANDBOX_DIR/test_take/nested/dir"
zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; take '$test_dir'" >/dev/null 2>&1
assert_success $? "take should create directory hierarchy"
assert_dir_exists "$test_dir" "Directory should exist after take"

# Test 3: extract with no arguments returns error
zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract" >/dev/null 2>&1
assert_failure $? 1 "extract with no arguments should return exit code 1"

# Test 4: extract with non-existent file returns error and prints [ERROR]
out=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract '/nonexistent/fake.zip' 2>&1")
status=$?
assert_failure $status 1 "extract with missing file should return 1"
assert_output_contains "$out" "[ERROR] Extracted 0 archive(s); 1 failed."

# Test 5: extract valid tar.gz archive
tar_target="$SANDBOX_DIR/archive_test"
mkdir -p "$tar_target/content"
echo "hello world" > "$tar_target/content/sample.txt"
tar -czf "$tar_target/test.tar.gz" -C "$tar_target/content" sample.txt
rm -rf "$tar_target/content"

(
  cd "$tar_target" || exit 1
  zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract test.tar.gz" >/dev/null 2>&1
)
assert_success $? "extract should succeed on valid tar.gz"
assert_file_exists "$tar_target/sample.txt" "Extracted file should exist"

teardown_sandbox
echo "helpers.zsh tests passed successfully!"
