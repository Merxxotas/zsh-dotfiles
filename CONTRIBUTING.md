# Contributing to ZSH Dotfiles

Thank you for contributing to the ZSH Dotfiles project! To maintain high reliability, security, and portability, please follow these guidelines.

---

## 1. Development Workflow

### Prerequisites
- `bash` (4.0+)
- `zsh` (5.8+)
- `python3` (for theme JSON validation)
- `git`

### Local Testing Commands

All checks must pass before opening a pull request:

```bash
# Run syntax and security pattern checks
make lint

# Run the complete automated test suite (pure offline)
make test

# Run installer integration tests
make test-installer

# Run runtime unit tests
make test-runtime

# Run full verification (lint + test + clean git status)
make verify
```

---

## 2. Core Principles & Rules

1. **Zero Network During Startup**: Never introduce `curl`, `wget`, or `git` commands into `.zshrc`, `.zshenv`, or startup modules.
2. **Deterministic Locking**:
   - New plugins must be pinned to exact 40-character commit SHAs in [`plugins.lock`](./plugins.lock).
   - Standalone tools must have exact versions, URLs, and SHA256 checksums in [`dependencies.lock`](./dependencies.lock).
3. **No Blind Error Suppression**: Never use `|| true` on critical path operations without explicit warning and error code handling.
4. **POSIX Portability**: Use `command -v` instead of `which`. Avoid GNU-only flags unless guarded by capability checks.
5. **Safe File Handling**: Quote all parameter expansions and escape dynamic paths when inserting into buffers (`${(q)var}`).

---

## 3. Pull Request Checklist

Before submitting your PR:
- [ ] Added automated tests in `tests/unit/` or `tests/integration/` for any new logic or bug fixes.
- [ ] Verified that `make verify` passes with 0 failures.
- [ ] Confirmed that working directory is clean (`git status`).
- [ ] Formatted commit messages following [Conventional Commits](https://www.conventionalcommits.org/).
