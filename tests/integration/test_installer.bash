#!/usr/bin/env bash
# =========================================================
# tests/integration/test_installer.bash - Integration Tests
# =========================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running integration tests for install.sh..."

# Test 1: Clean copy installation
(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export HOME="$SANDBOX_DIR/home_copy"
  mkdir -p "$HOME"

  "$SCRIPT_DIR/install.sh" --mode copy --no-deps --yes >/dev/null
  assert_success $? "Clean copy install should succeed"
  assert_is_regular_dir "$HOME/.config/zsh" "ZDOTDIR should be a regular directory"
  assert_is_regular_file "$HOME/.config/zsh/.zshrc" ".zshrc should be a regular file in copy mode"
  assert_is_regular_file "$HOME/.zshenv" ".zshenv should be a regular file in copy mode"
)

# Test 2: Clean symlink installation
(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export HOME="$SANDBOX_DIR/home_symlink"
  mkdir -p "$HOME"

  "$SCRIPT_DIR/install.sh" --mode symlink --no-deps --yes >/dev/null
  assert_success $? "Clean symlink install should succeed"
  assert_is_regular_dir "$HOME/.config/zsh" "ZDOTDIR should be a regular directory containing symlinks"
  assert_is_symlink "$HOME/.config/zsh/.zshrc" ".zshrc should be a symlink in symlink mode"
  assert_is_symlink "$HOME/.zshenv" ".zshenv should be a symlink in symlink mode"
  assert_link_target "$HOME/.config/zsh/.zshrc" "$SCRIPT_DIR/.config/zsh/.zshrc"
  assert_link_target "$HOME/.zshenv" "$SCRIPT_DIR/.zshenv"
)

# Test 3: Transition Copy -> Symlink with local.zsh preservation
(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export HOME="$SANDBOX_DIR/home_trans"
  mkdir -p "$HOME"

  # Step 1: Copy install
  "$SCRIPT_DIR/install.sh" --mode copy --no-deps --yes >/dev/null
  echo "CUSTOM_LOCAL_SECRET=12345" > "$HOME/.config/zsh/local.zsh"

  # Step 2: Switch to symlink mode
  "$SCRIPT_DIR/install.sh" --mode symlink --no-deps --yes >/dev/null
  assert_success $? "Switching from copy to symlink mode should succeed"
  assert_file_contains "$HOME/.config/zsh/local.zsh" "CUSTOM_LOCAL_SECRET=12345"
  assert_is_symlink "$HOME/.config/zsh/.zshrc"
)

# Test 4: Transition Symlink -> Copy
(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export HOME="$SANDBOX_DIR/home_trans2"
  mkdir -p "$HOME"

  # Step 1: Symlink install
  "$SCRIPT_DIR/install.sh" --mode symlink --no-deps --yes >/dev/null
  assert_is_symlink "$HOME/.config/zsh/.zshrc"

  # Step 2: Switch to copy mode
  "$SCRIPT_DIR/install.sh" --mode copy --no-deps --yes >/dev/null
  assert_success $? "Switching from symlink to copy mode should succeed"
  assert_is_regular_file "$HOME/.config/zsh/.zshrc"
)

# Test 5: Unknown options exit with code 2
(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export HOME="$SANDBOX_DIR/home_err"
  mkdir -p "$HOME"

  "$SCRIPT_DIR/install.sh" --unsupported-flag >/dev/null 2>&1
  assert_failure $? 2 "Unknown options should return exit code 2"
)

# Test 6: Dry-run makes zero modifications
(
  unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_DATA_HOME XDG_STATE_HOME
  export HOME="$SANDBOX_DIR/home_dry"
  mkdir -p "$HOME"

  "$SCRIPT_DIR/install.sh" --dry-run >/dev/null
  assert_success $? "Dry-run should succeed"
  assert_not_exists "$HOME/.config/zsh" "Dry-run should not create .config/zsh"
  assert_not_exists "$HOME/.zshenv" "Dry-run should not create .zshenv"
)

teardown_sandbox
echo "install.sh integration tests passed successfully!"
