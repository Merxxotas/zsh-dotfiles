# Changelog

All notable changes to the ZSH Dotfiles suite are documented here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Each entry corresponds to a GitHub Release. The authoritative, human-written notes for every release live on the [Releases page](https://github.com/Merxxotas/zsh-dotfiles/releases); this file is the in-repository, offline-readable index.

---

## [Unreleased]

Nothing yet.

---

## [2.4.0] — 2026-10-20

### Added
- Workspace safety guards in `dev-env.zsh`: `gentle-shell`, `gentle-ai` and `git init` refuse to run directly in `$HOME`. Bypasses: `GENTLE_ALLOW_HOME=1`, `GIT_ALLOW_HOME_INIT=1`.
- `gentle-ai` administrative and read-only subcommands (`doctor`, `version`, `help`, `update`, `telemetry`, `restore`) remain allowed without a bypass.
- New suite `TS-07` (`tests/unit/test_dev_env.bash`) covering the guards, subcommands, bypass flags and subdirectories; wired into `make test-runtime`.

### Changed
- `JOB_QUEUE_TMPDIR` and `ABBR_TMPDIR` now resolve to `${XDG_RUNTIME_DIR:-/tmp}/zsh-<tool>-$UID`, isolating `zsh-abbr` and `zsh-job-queue` temp dirs per user.

### Documentation
- `wiki/01-Architecture-and-XDG.md`, `wiki/03-Dev-Environment-and-Tooling.md`, `wiki/07-Testing-and-CI-CD.md`, `README.md` and `TEST_SCENARIOS.md` updated for the guards and the temp-dir isolation.

---

## [2.3.0] — 2026-09-24

### Added
- `$HOME/.npm-global/bin` added to the universal `PATH` array in `.config/zsh/.zshenv`, making user-space npm CLI tools available in every interactive and non-interactive subshell without `sudo`.
- `TS-04` extended to assert `.npm-global/bin` presence in `PATH`.

### Documentation
- Global npm PATH resolution documented in `wiki/03-Dev-Environment-and-Tooling.md`.

---

## [2.2.0] — 2026-09-11

### Added
- Multi-part and split archive detection in the universal `extract` utility: RAR (`*.part*.rar`, `*.r00`…), 7-Zip (`*.7z.001`…) and ZIP (`*.z01`…).
- Batch deduplication: `extract` extracts the primary volume and skips auxiliary volumes with an informative notice instead of prompting.
- Standalone auxiliary volume redirection: pointing `extract` at `archive.part05.rar` resolves the primary volume automatically.
- `TS-05` extended with multi-volume archive coverage.

### Fixed
- Interactive overwrite prompts removed from the extraction flow, eliminating terminal lockups.

---

## [2.1.0] — 2026-09-09

### Added
- Official GitHub Wiki with 11 modular pages and native sidebar navigation, sourced from `wiki/` in this repository.
- Automated wiki sync via `.github/workflows/wiki-sync.yml`, publishing `wiki/**` on every push to `main`.
- PNPM v11 support: `$PNPM_HOME/bin` injected into `PATH` in `.config/zsh/.zshenv`.
- High-performance command correction: `thefuck` replaced by `pay-respects`, aliased to `fuck` with `--nocnf`.
- IntelliShell AI navigation and Atuin encrypted history.

### Changed
- CI pipelines hardened across all supported Linux distributions.

---

## [2.0.0] — 2026-09-01

### Added
- Deterministic plugin pinning: all 8 ZSH plugins locked to immutable 40-character commit SHAs in `plugins.lock`.
- Verified binary fallbacks: `yt-dlp`, `oh-my-posh` and `atuin` pinned to release versions with SHA256 checksums in `dependencies.lock`.
- 100% offline startup: zero network requests during normal shell initialization; `zplugin-install` / `zplugin-update` handle explicit sync.
- Strict installer CLI: `--mode copy|symlink`, `-s`, `-y`, `--no-deps`, `--dry-run`, `--list-backups`, `--restore <id>`.
- File-by-file symlink architecture keeping `~/.config/zsh` a real directory while isolating `local.zsh` outside Git.
- Transactional backups with manifest tracking under `$XDG_STATE_HOME/zsh/backups/`.
- Pure offline test suite (`tests/run_tests.sh`, `tests/helpers/`) and a developer Makefile.

---

[Unreleased]: https://github.com/Merxxotas/zsh-dotfiles/compare/v2.4.0...HEAD
[2.4.0]: https://github.com/Merxxotas/zsh-dotfiles/compare/v2.3.0...v2.4.0
[2.3.0]: https://github.com/Merxxotas/zsh-dotfiles/compare/v2.2.0...v2.3.0
[2.2.0]: https://github.com/Merxxotas/zsh-dotfiles/compare/v2.1.0...v2.2.0
[2.1.0]: https://github.com/Merxxotas/zsh-dotfiles/compare/v2.0.0...v2.1.0
[2.0.0]: https://github.com/Merxxotas/zsh-dotfiles/releases/tag/v2.0.0
