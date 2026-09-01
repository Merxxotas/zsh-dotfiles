#!/usr/bin/env bash
# ==============================================================================
# tests/run_tests.sh - Test Runner for ZSH Dotfiles Suite
# ==============================================================================

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BLUE}${BOLD}================================================================${NC}"
echo -e "${BLUE}${BOLD}       Running ZSH Dotfiles Automated Test Suite        ${NC}"
echo -e "${BLUE}${BOLD}================================================================${NC}\n"

passed=0
failed=0
total=0

test_files=()
for f in "$SCRIPT_DIR/tests/unit"/test_*.bash "$SCRIPT_DIR/tests/integration"/test_*.bash; do
  [ -f "$f" ] && test_files+=("$f")
done

for test_script in "${test_files[@]}"; do
  rel_path="${test_script#$SCRIPT_DIR/}"
  total=$((total + 1))
  echo -e "${BOLD}[RUN]${NC} $rel_path"
  
  if bash "$test_script"; then
    echo -e "  ${GREEN}[PASS]${NC} $rel_path\n"
    passed=$((passed + 1))
  else
    echo -e "  ${RED}[FAIL]${NC} $rel_path\n"
    failed=$((failed + 1))
  fi
done

echo -e "${BOLD}================================================================${NC}"
echo -e "Test Summary: ${GREEN}$passed passed${NC}, ${RED}$failed failed${NC}, $total total"
echo -e "${BOLD}================================================================${NC}"

if [ "$failed" -gt 0 ]; then
  exit 1
fi
exit 0
