#!/usr/bin/env bash
# ==============================================================================
# tests/unit/test_media.bash - Unit tests for media.zsh
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$SCRIPT_DIR/tests/helpers/assertions.bash"
source "$SCRIPT_DIR/tests/helpers/sandbox.bash"

setup_sandbox

echo "Running unit tests for media.zsh..."

# Test 1: vdl with missing argument to -f returns code 2
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vdl 'https://example.com' -f" >/dev/null 2>&1
assert_failure $? 2 "vdl with missing -f value should return code 2"

# Test 2: vdl with invalid quality returns code 2
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vdl 'https://example.com' -q not_a_number" >/dev/null 2>&1
assert_failure $? 2 "vdl with invalid quality should return code 2"

# Test 3: vdl with unknown option returns code 2
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vdl 'https://example.com' --bad-flag" >/dev/null 2>&1
assert_failure $? 2 "vdl with unknown flag should return code 2"

# Test 4: vconv with missing input returns code 1
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vconv '/nonexistent/fake.webm' mp4" >/dev/null 2>&1
assert_failure $? 1 "vconv with missing file should return code 1"

# Test 5: vaudio with missing input returns code 1
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vaudio '/nonexistent/fake.mp4'" >/dev/null 2>&1
assert_failure $? 1 "vaudio with missing file should return code 1"

# Test 6: vcut with missing input returns code 1
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vcut '/nonexistent/fake.mp4' 00:00:01 00:00:05" >/dev/null 2>&1
assert_failure $? 1 "vcut with missing file should return code 1"

# Test 7: vgif with missing input returns code 1
zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vgif '/nonexistent/fake.mp4'" >/dev/null 2>&1
assert_failure $? 1 "vgif with missing file should return code 1"

teardown_sandbox
echo "media.zsh tests passed successfully!"
