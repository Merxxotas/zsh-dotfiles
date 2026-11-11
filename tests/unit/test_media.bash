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

# Test 8: vconv with unknown option returns code 1
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vconv --invalid-opt 'dummy.webm' mp4" 2>&1)
assert_failure $? 1 "vconv with unknown option should return code 1"
assert_output_contains "$output" "Unknown option" "vconv should report unknown option"

# Test 8b: vconv with -h and --help displays usage and returns code 0
output_h=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vconv -h" 2>&1)
assert_success $? "vconv -h should return code 0"
assert_output_contains "$output_h" "Usage: vconv [options]" "vconv -h should display usage"

output_help=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vconv --help" 2>&1)
assert_success $? "vconv --help should return code 0"
assert_output_contains "$output_help" "Universal video transcoder" "vconv --help should display usage description"

# Test 9: vconv --gpu when hwaccel is cpu returns code 1
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export _VCONV_HWACCEL_CACHE=cpu; vconv --gpu 'dummy.webm' mp4" 2>&1)
assert_failure $? 1 "vconv --gpu without GPU should return code 1"
assert_output_contains "$output" "no GPU hardware video encoder was detected" "vconv --gpu should report error"

# Test 10: vconv CPU warning triggers for >= 180s and stays silent for < 180s
mock_command "ffprobe" 'echo "210.45"'
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export PATH=\"$SANDBOX_DIR/mock_bin:\$PATH\"; _vconv_warn_cpu_if_long 'long.mp4' 'libx264'")
assert_output_contains "$output" "videos > 3 min" "vconv warning should trigger for >= 180s videos"

mock_command "ffprobe" 'echo "45.00"'
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export PATH=\"$SANDBOX_DIR/mock_bin:\$PATH\"; _vconv_warn_cpu_if_long 'short.mp4' 'libx264'")
assert_equal "$output" "" "vconv warning should NOT trigger for short videos < 180s"

# Test 11: vconv with mock ffmpeg verifying GPU encoding and fallback
dummy_in="$SANDBOX_DIR/sample.webm"
touch "$dummy_in"

mock_command "ffmpeg" '
for arg in "$@"; do
  if [[ "$arg" == "h264_nvenc" ]]; then
    echo "ENCODED_WITH_NVENC"
    touch "${@: -1}"
    exit 0
  elif [[ "$arg" == "libx264" ]]; then
    echo "ENCODED_WITH_CPU"
    touch "${@: -1}"
    exit 0
  elif [[ "$arg" == "mpeg4" ]]; then
    echo "ENCODED_WITH_MPEG4"
    touch "${@: -1}"
    exit 0
  fi
done
touch "${@: -1}"
exit 0
'

output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export PATH=\"$SANDBOX_DIR/mock_bin:\$PATH\"; export _VCONV_HWACCEL_CACHE=nvenc; vconv '$dummy_in' mp4" 2>&1)
assert_success $? "vconv with nvenc should succeed"
assert_output_contains "$output" "GPU: nvenc" "vconv should report nvenc usage"

# Test 12: vconv --cpu forces CPU despite GPU cache
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export PATH=\"$SANDBOX_DIR/mock_bin:\$PATH\"; export _VCONV_HWACCEL_CACHE=nvenc; vconv --cpu '$dummy_in' mp4" 2>&1)
assert_success $? "vconv --cpu should succeed"
assert_output_contains "$output" "ENCODED_WITH_CPU" "vconv --cpu should use CPU"

# Test 13: vconv to avi uses MPEG-4 encoder
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export PATH=\"$SANDBOX_DIR/mock_bin:\$PATH\"; vconv '$dummy_in' avi" 2>&1)
assert_success $? "vconv to avi should succeed"
assert_output_contains "$output" "Using legacy MPEG-4/XviD encoder" "vconv to avi should report MPEG-4"

# Test 14: vconv hot fallback to CPU when GPU fails
mock_command "ffmpeg" '
for arg in "$@"; do
  if [[ "$arg" == "h264_nvenc" ]]; then
    echo "NVENC_FAILURE_SIMULATED" >&2
    exit 1
  elif [[ "$arg" == "libx264" ]]; then
    echo "RETRY_WITH_CPU_SUCCESS"
    touch "${@: -1}"
    exit 0
  fi
done
exit 0
'

output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export PATH=\"$SANDBOX_DIR/mock_bin:\$PATH\"; export _VCONV_HWACCEL_CACHE=nvenc; vconv '$dummy_in' mp4" 2>&1)
assert_success $? "vconv fallback should succeed"
assert_output_contains "$output" "GPU encoding failed" "vconv should warn about GPU failure"
assert_output_contains "$output" "RETRY_WITH_CPU_SUCCESS" "vconv should fall back to CPU"

# Test 15: vconv --gpu rejects incompatible flags and unsupported formats
output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export _VCONV_HWACCEL_CACHE=nvenc; vconv --gpu --lossless '$dummy_in' mp4" 2>&1)
assert_failure $? 1 "vconv --gpu --lossless should return code 1"
assert_output_contains "$output" "cannot be combined with --lossless" "vconv should reject --gpu --lossless"

output=$(zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; export _VCONV_HWACCEL_CACHE=nvenc; vconv --gpu '$dummy_in' avi" 2>&1)
assert_failure $? 1 "vconv --gpu to avi should return code 1"
assert_output_contains "$output" "does not support GPU encoding" "vconv should reject --gpu for avi"

# Test 16: vconv -h works without ffmpeg in PATH
mkdir -p "$SANDBOX_DIR/no_ffmpeg"
ln -sf "$(command -v zsh)" "$SANDBOX_DIR/no_ffmpeg/zsh"
output=$(PATH="$SANDBOX_DIR/no_ffmpeg" zsh -c "source '$SCRIPT_DIR/.config/zsh/media.zsh'; vconv -h" 2>&1)
assert_success $? "vconv -h should succeed even without ffmpeg"
assert_output_contains "$output" "Usage: vconv [options]" "vconv -h should show usage without ffmpeg"

teardown_sandbox
echo "media.zsh tests passed successfully!"
