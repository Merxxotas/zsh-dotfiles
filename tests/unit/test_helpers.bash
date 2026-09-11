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

# Test 6: multipart RAR missing primary volume reports error
multi_rar_dir="$SANDBOX_DIR/multi_rar_test"
mkdir -p "$multi_rar_dir"
touch "$multi_rar_dir/archive.part02.rar"
out_rar=$(cd "$multi_rar_dir" && zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract archive.part02.rar 2>&1")
status_rar=$?
assert_failure $status_rar 1 "extract secondary RAR part without primary should fail"
assert_output_contains "$out_rar" "primary volume 'archive.part01.rar' not found"

# Test 7: multipart 7z missing primary volume reports error
multi_7z_err_dir="$SANDBOX_DIR/multi_7z_err_test"
mkdir -p "$multi_7z_err_dir"
touch "$multi_7z_err_dir/bundle.7z.002"
out_7z_err=$(cd "$multi_7z_err_dir" && zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract bundle.7z.002 2>&1")
status_7z_err=$?
assert_failure $status_7z_err 1 "extract secondary 7z part without primary should fail"
assert_output_contains "$out_7z_err" "primary volume 'bundle.7z.001' not found"

# Test 8: multipart 7z batch extraction and skipping auxiliary volumes
if command -v 7z >/dev/null 2>&1; then
  multi_7z_dir="$SANDBOX_DIR/multi_7z_test"
  mkdir -p "$multi_7z_dir/src"
  echo "multipart content payload" > "$multi_7z_dir/src/payload.txt"
  (
    cd "$multi_7z_dir" || exit 1
    7z a -v50b archive.7z src/payload.txt >/dev/null 2>&1
    rm -rf src
  )
  out_multi=$(cd "$multi_7z_dir" && zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract archive.7z.001 archive.7z.002 2>&1")
  status_multi=$?
  assert_success $status_multi "multipart batch extraction should succeed"
  assert_file_exists "$multi_7z_dir/src/payload.txt" "Payload should be extracted from multipart archive"
  assert_output_contains "$out_multi" "Skipping auxiliary multi-part volume 'archive.7z.002'"

  # Test 9: extracting secondary volume when primary exists triggers primary extraction
  mkdir -p "$multi_7z_dir/test_secondary"
  cp "$multi_7z_dir"/archive.7z.* "$multi_7z_dir/test_secondary/"
  out_sec=$(cd "$multi_7z_dir/test_secondary" && zsh -c "source '$SCRIPT_DIR/.config/zsh/helpers.zsh'; extract archive.7z.002 2>&1")
  status_sec=$?
  assert_success $status_sec "extracting secondary volume with primary present should succeed"
  assert_file_exists "$multi_7z_dir/test_secondary/src/payload.txt" "Payload should be extracted when invoking secondary volume"
  assert_output_contains "$out_sec" "Extracting primary volume 'archive.7z.001'"
fi

teardown_sandbox
echo "helpers.zsh tests passed successfully!"
