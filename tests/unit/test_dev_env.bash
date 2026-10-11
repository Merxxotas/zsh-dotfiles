#!/usr/bin/env bash
# ==============================================================================
# tests/unit/test_dev_env.bash - Unit tests for dev-env.zsh workspace guards
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running unit tests for dev-env.zsh..."

# Test 1: gentle-shell in $HOME fails with exit code 1 and error message
(
  out=$(cd "$SANDBOX_DIR" && zsh -c "HOME='$SANDBOX_DIR'; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; gentle-shell 2>&1")
  status=$?
  assert_failure $status 1 "gentle-shell in \$HOME should exit with code 1"
  assert_output_contains "$out" "[ERROR] Cannot run gentle-shell directly in \$HOME (~)."
)

# Test 2: gentle-shell with GENTLE_ALLOW_HOME=1 bypasses home check
(
  # Mock underlying gentle-shell command in a fake PATH
  mock_bin="$SANDBOX_DIR/mock_bin"
  mkdir -p "$mock_bin"
  echo '#!/bin/sh' > "$mock_bin/gentle-shell"
  echo 'echo "mock gentle-shell executed"' >> "$mock_bin/gentle-shell"
  chmod +x "$mock_bin/gentle-shell"

  out=$(PATH="$mock_bin:$PATH" cd "$SANDBOX_DIR" && zsh -c "HOME='$SANDBOX_DIR'; GENTLE_ALLOW_HOME=1; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; gentle-shell 2>&1")
  status=$?
  assert_success $status "gentle-shell with GENTLE_ALLOW_HOME=1 should bypass guard"
  assert_output_contains "$out" "mock gentle-shell executed"
)

# Test 3: gentle-shell in a subdirectory passes guard check
(
  mock_bin="$SANDBOX_DIR/mock_bin"
  mkdir -p "$mock_bin" "$SANDBOX_DIR/project"
  echo '#!/bin/sh' > "$mock_bin/gentle-shell"
  echo 'echo "mock gentle-shell in project"' >> "$mock_bin/gentle-shell"
  chmod +x "$mock_bin/gentle-shell"

  out=$(PATH="$mock_bin:$PATH" cd "$SANDBOX_DIR/project" && zsh -c "HOME='$SANDBOX_DIR'; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; gentle-shell 2>&1")
  status=$?
  assert_success $status "gentle-shell in project directory should succeed"
  assert_output_contains "$out" "mock gentle-shell in project"
)

# Test 4: gentle-ai with mutating/review subcommand in $HOME fails with exit code 1
(
  out=$(cd "$SANDBOX_DIR" && zsh -c "HOME='$SANDBOX_DIR'; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; gentle-ai review 2>&1")
  status=$?
  assert_failure $status 1 "gentle-ai review in \$HOME should exit with code 1"
  assert_output_contains "$out" "[ERROR] Cannot run 'gentle-ai review' directly in \$HOME (~)."
)

# Test 5: gentle-ai with whitelisted info subcommand (doctor) passes guard check
(
  mock_bin="$SANDBOX_DIR/mock_bin"
  mkdir -p "$mock_bin"
  echo '#!/bin/sh' > "$mock_bin/gentle-ai"
  echo 'echo "mock gentle-ai doctor output"' >> "$mock_bin/gentle-ai"
  chmod +x "$mock_bin/gentle-ai"

  out=$(PATH="$mock_bin:$PATH" cd "$SANDBOX_DIR" && zsh -c "HOME='$SANDBOX_DIR'; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; gentle-ai doctor 2>&1")
  status=$?
  assert_success $status "gentle-ai doctor in \$HOME should be permitted"
  assert_output_contains "$out" "mock gentle-ai doctor output"
)

# Test 6: git init in $HOME fails with exit code 1 and error message
(
  out=$(cd "$SANDBOX_DIR" && zsh -c "HOME='$SANDBOX_DIR'; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; git init 2>&1")
  status=$?
  assert_failure $status 1 "git init in \$HOME should exit with code 1"
  assert_output_contains "$out" "[ERROR] Refusing to initialize a Git repository directly in \$HOME (~)."
)

# Test 7: git init with GIT_ALLOW_HOME_INIT=1 bypasses home check
(
  test_home="$SANDBOX_DIR/test_override_home"
  mkdir -p "$test_home"
  out=$(cd "$test_home" && zsh -c "HOME='$test_home'; GIT_ALLOW_HOME_INIT=1; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; git init 2>&1")
  status=$?
  assert_success $status "git init with GIT_ALLOW_HOME_INIT=1 should be permitted"
  assert_dir_exists "$test_home/.git" ".git directory should exist after permitted git init"
)

# Test 8: git init in a project subdirectory succeeds
(
  project_dir="$SANDBOX_DIR/test_project"
  mkdir -p "$project_dir"
  out=$(cd "$project_dir" && zsh -c "HOME='$SANDBOX_DIR'; source '$SCRIPT_DIR/.config/zsh/dev-env.zsh'; git init 2>&1")
  status=$?
  assert_success $status "git init in project directory should succeed"
  assert_dir_exists "$project_dir/.git" ".git directory should exist in project directory"
)

teardown_sandbox
echo "dev-env.zsh tests passed successfully!"
