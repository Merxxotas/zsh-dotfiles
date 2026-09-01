# ==============================================================================
# Makefile - Development, Testing and Verification Suite
# ==============================================================================

.PHONY: all lint test test-installer test-runtime verify clean help

all: verify

help:
	@echo "Available targets:"
	@echo "  make lint            Run static syntax checks and security pattern linter"
	@echo "  make test            Run full automated test suite"
	@echo "  make test-installer  Run installer integration tests"
	@echo "  make test-runtime    Run runtime unit tests (media, helpers, env, themes, plugins)"
	@echo "  make verify          Run lint, full test suite and clean checkout verification"

lint:
	@echo "==> Validating Bash scripts..."
	@bash -n install.sh
	@for f in tests/**/*.bash tests/*.sh; do [ -f "$$f" ] && bash -n "$$f"; done
	@if command -v shellcheck >/dev/null 2>&1; then \
		echo "==> Running ShellCheck..."; \
		shellcheck -e SC1091,SC2086,SC2034 install.sh; \
	fi
	@echo "==> Validating ZSH scripts..."
	@zsh -n .zshenv .config/zsh/.zshenv .config/zsh/.zshrc .config/zsh/*.zsh
	@echo "==> Validating Theme JSONs..."
	@python3 -c "import json, glob; [json.load(open(f)) for f in glob.glob('.config/zsh/themes/*.omp.json')]; print('JSON valid: all themes ok')"
	@echo "==> Checking forbidden security patterns..."
	@! grep -rnE 'curl\s+.*\|\s*(ba)?sh' install.sh .config/zsh/ || { echo "[ERROR] Detected forbidden curl | sh execution!"; exit 1; }
	@echo "[OK] All lint and security checks passed."

test:
	@./tests/run_tests.sh

test-installer:
	@bash tests/integration/test_installer.bash

test-runtime:
	@bash tests/unit/test_helpers.bash
	@bash tests/unit/test_media.bash
	@bash tests/unit/test_prompt.bash
	@bash tests/unit/test_env.bash
	@bash tests/unit/test_plugins.bash

verify: lint test
	@echo "==> Verifying clean git state..."
	@if [ -n "$$(git status --porcelain | grep -v '^??')" ]; then \
		echo "[WARN] Working directory has unstaged modifications."; \
	else \
		echo "[OK] Working tree clean."; \
	fi
	@echo "[OK] Verification complete successfully."
