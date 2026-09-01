#!/usr/bin/env bash
# ==============================================================================
# tests/helpers/assertions.bash - Test Assertion Library
# ==============================================================================

# Assert that exit status is 0
assert_success() {
  local status="$1"
  local message="${2:-Expected command to succeed, but got exit code $status}"
  if [ "$status" -ne 0 ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert that exit status is not 0 (or specific code)
assert_failure() {
  local status="$1"
  local expected_code="${2:-}"
  local message="${3:-Expected command to fail, but got exit code $status}"

  if [ "$status" -eq 0 ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi

  if [ -n "$expected_code" ] && [ "$status" -ne "$expected_code" ]; then
    echo "  [FAIL] Expected exit code $expected_code, but got $status" >&2
    return 1
  fi

  return 0
}

# Assert equality of two strings
assert_equal() {
  local actual="$1"
  local expected="$2"
  local message="${3:-Expected '$expected', but got '$actual'}"

  if [ "$actual" != "$expected" ]; then
    echo "  [FAIL] $message" >&2
    echo "         Expected: $expected" >&2
    echo "         Actual:   $actual" >&2
    return 1
  fi
  return 0
}

# Assert file exists
assert_file_exists() {
  local path="$1"
  local message="${2:-Expected file '$path' to exist}"

  if [ ! -f "$path" ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert directory exists
assert_dir_exists() {
  local path="$1"
  local message="${2:-Expected directory '$path' to exist}"

  if [ ! -d "$path" ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert file or dir does not exist
assert_not_exists() {
  local path="$1"
  local message="${2:-Expected '$path' not to exist}"

  if [ -e "$path" ] || [ -L "$path" ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert that path is a symlink
assert_is_symlink() {
  local path="$1"
  local message="${2:-Expected '$path' to be a symbolic link}"

  if [ ! -L "$path" ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert that path is a regular file (not a symlink)
assert_is_regular_file() {
  local path="$1"
  local message="${2:-Expected '$path' to be a regular file, not a symlink}"

  if [ -L "$path" ] || [ ! -f "$path" ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert that path is a regular directory (not a symlink)
assert_is_regular_dir() {
  local path="$1"
  local message="${2:-Expected '$path' to be a regular directory, not a symlink}"

  if [ -L "$path" ] || [ ! -d "$path" ]; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}

# Assert symlink points to expected target
assert_link_target() {
  local link="$1"
  local expected_target="$2"
  local message="${3:-Expected symlink '$link' to point to '$expected_target'}"

  if [ ! -L "$link" ]; then
    echo "  [FAIL] '$link' is not a symlink" >&2
    return 1
  fi

  local actual_target
  actual_target="$(readlink "$link")"

  if [ "$actual_target" != "$expected_target" ]; then
    echo "  [FAIL] $message" >&2
    echo "         Expected target: $expected_target" >&2
    echo "         Actual target:   $actual_target" >&2
    return 1
  fi
  return 0
}

# Assert that output contains a substring
assert_output_contains() {
  local output="$1"
  local pattern="$2"
  local message="${3:-Expected output to contain '$pattern'}"

  if [[ "$output" != *"$pattern"* ]]; then
    echo "  [FAIL] $message" >&2
    echo "         Actual output: $output" >&2
    return 1
  fi
  return 0
}

# Assert that file contains a substring
assert_file_contains() {
  local file="$1"
  local pattern="$2"
  local message="${3:-Expected file '$file' to contain '$pattern'}"

  if [ ! -f "$file" ]; then
    echo "  [FAIL] File '$file' does not exist" >&2
    return 1
  fi

  if ! grep -Fq -- "$pattern" "$file"; then
    echo "  [FAIL] $message" >&2
    return 1
  fi
  return 0
}
