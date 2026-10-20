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

The non-negotiable rules live in **[`AGENTS.md`](./AGENTS.md) § 3 — Invariants**, which is the canonical, machine-readable contract for this repository. Summary:

- **Zero network during startup** — no `curl`, `wget` or `git` in the startup path.
- **Deterministic locking** — plugins pinned to 40-character commit SHAs, binaries pinned to version + SHA256.
- **No blind error suppression** — no `|| true` on critical paths.
- **POSIX portability** — `command -v`, never `which`; guard GNU-only flags.
- **Safe file handling** — quote expansions, escape dynamic paths with `${(q)var}`.

This summary is illustrative only. `AGENTS.md` also carries the repository map, which command to run for which change, per-file rules and known traps.

---

## 3. Pull Request Checklist

Before submitting your PR:
- [ ] Added automated tests in `tests/unit/` or `tests/integration/` for any new logic or bug fixes.
- [ ] Verified that `make verify` passes with 0 failures.
- [ ] Confirmed that working directory is clean (`git status`).
- [ ] Formatted commit messages following [Conventional Commits](https://www.conventionalcommits.org/).
- [ ] Updated [`AGENTS.md`](./AGENTS.md), [`CHANGELOG.md`](./CHANGELOG.md) or the [`wiki/`](./wiki/) chapters if the change affects them.
