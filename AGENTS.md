# AGENTS.md — Working Contract for ZSH Dotfiles

Operational contract for any agent or contributor working in this repository: what the project is, where things live, which invariants must not break, how to verify a change, and which traps to avoid.

**Scope.** This file is canonical for *how to work in this repo*. Conceptual documentation — architecture, installer design, multimedia suite, themes, plugins, security model — lives in [`wiki/`](./wiki/) and is published to the [GitHub Wiki](https://github.com/Merxxotas/zsh-dotfiles/wiki). Link to the wiki from here; do not restate it.

---

## 1. What this project is

A modular, XDG-compliant ZSH configuration suite with a supply-chain-hardened installer, offline startup, and a multi-distribution CI matrix. Shell modules live in `.config/zsh/` and are installed to `~/.config/zsh`.

Four constraints shape every change:

| Constraint | Rule |
| :--- | :--- |
| Startup latency | No network and no blocking work in startup modules. Target < 30ms. |
| Supply chain | Plugins pinned to 40-char commit SHAs; standalone binaries pinned to version + SHA256. |
| Portability | Must run on Debian/Ubuntu, Arch/Fedora/openSUSE, RHEL/Alma/Rocky, Alpine, Gentoo and macOS. |
| Offline tests | The whole suite must run with no network access. |

---

## 2. Repository map

| Path | What it is | Touch it when |
| :--- | :--- | :--- |
| `.zshenv` | Root fallback: `TERM` fallback, redirects `ZDOTDIR` to `~/.config/zsh` | Changing what happens before `ZDOTDIR` resolves |
| `.config/zsh/.zshenv` | XDG dirs, consolidated `PATH`, per-user temp dirs | `PATH`, XDG or temp-dir changes |
| `.config/zsh/.zshrc` | History, shell options, compinit cache, module load order, `local.zsh` hook | Adding, removing or reordering modules |
| `.config/zsh/fzf.zsh` … `prompt.zsh` | Startup modules, sourced in the order below | Feature work inside that module |
| `.config/zsh/themes/*.omp.json` | Oh-My-Posh themes (`tokyo` = root, `clean-detailed` = user) | Theme content |
| `.config/zsh/local.zsh.example` | Template for host-local secrets. `local.zsh` itself is git-ignored | Documenting a new local-only setting |
| `install.sh` | Universal installer: copy/symlink modes, transactional backups, restore | Installer behavior or flags |
| `Makefile` | Verification entry points | Adding a check or a target |
| `tests/unit/`, `tests/integration/` | Offline suites, IDs `TS-01`…`TS-07` | Any behavior change or bug fix |
| `tests/helpers/` | `assertions.bash` (assertions) and `sandbox.bash` (`setup_sandbox`, `teardown_sandbox`, `mock_command`) | Adding shared test utilities |
| `plugins.lock` | 8 plugins pinned to commit SHAs | Adding or updating a plugin |
| `dependencies.lock` | Standalone binaries with version, URL and SHA256 | Adding or updating a binary |
| `wiki/` | Canonical conceptual docs, auto-synced to the GitHub Wiki | Conceptual and architectural docs |
| `docs/archive/` | Historical planning documents — **not** active work | Nothing |
| `.github/workflows/` | CI matrix, lint, unit tests, wiki sync | CI behavior |

**Module load order** (from `.config/zsh/.zshrc`): `fzf.zsh`, `helpers.zsh`, `media.zsh`, `plugins.zsh`, `aliases.zsh`, `bindings.zsh`, `dev-env.zsh`, `fzf-tab.zsh`, `prompt.zsh`, then `local.zsh` if it exists. A module must not depend on state defined later in that list.

---

## 3. Invariants — do not break these

1. **No network at startup.** No `curl`, `wget` or `git` invocations in `.zshenv`, `.zshrc` or any startup module. Maintenance commands are explicit and separate.
2. **Deterministic locking.** A new plugin gets an exact 40-character commit SHA in `plugins.lock`. A new standalone binary gets an exact version, URL and SHA256 in `dependencies.lock`.
3. **No blind error suppression.** No `|| true` on a critical path without explicit error handling and an exit code.
4. **POSIX portability.** `command -v`, never `which`. Guard GNU-only flags behind capability checks.
5. **Safe buffer handling.** Quote expansions and escape dynamic paths with `${(q)var}`.
6. **Root/user isolation.** Root prompt theme is `tokyo`, user theme is `clean-detailed`. Keep them isolated.
7. **Secrets stay out of Git.** Host-specific values belong in `.config/zsh/local.zsh` (ignored, mode `0600`).

---

## 4. Verification

| Change | Run | Gate |
| :--- | :--- | :--- |
| Any shell file (`.zsh`, `.sh`, `.bash`) | `make lint` | No syntax errors, no forbidden `curl \| sh` pattern, themes parse as JSON |
| Behavior change or bug fix in a startup module | `make test-runtime` | All suites pass, 0 failures |
| `install.sh` or installer flow | `make test-installer` | All suites pass |
| Full suite before opening a PR | `make verify` | `lint` + `test` green |
| Documentation | No test target applies. Check that every relative link resolves and that the TS matrix in `wiki/07` is updated if a suite changed | Reviewer |

How the targets behave:

- `make test` runs every `tests/unit/test_*.bash` and `tests/integration/test_*.bash` through `tests/run_tests.sh`, and exits non-zero if any suite fails.
- `make lint` runs `bash -n` over `install.sh` and the test scripts, `zsh -n` over the ZSH files, a `python3` JSON parse of the themes, and a grep for forbidden `curl | sh` patterns. ShellCheck runs **only if the binary is installed**; CI always installs it.
- `make verify` runs `lint` + `test` and then **warns** — it does not fail — when tracked files are modified. Untracked files are ignored entirely. A green `make verify` is not a statement that the tree is clean.
- `make clean` is declared but has no recipe, so it is a no-op. There is no cleanup target.
- CI also runs `./install.sh -y` on every supported distribution and then boots an interactive ZSH to assert the install actually works. A change to the installer must survive that path, not just the unit tests.

---

## 5. Adding a test

- Unit suite: `tests/unit/test_<module>.bash`. Integration suite: `tests/integration/test_<subject>.bash`.
- Use the shared helpers instead of ad-hoc assertions:
  - `tests/helpers/assertions.bash`: `assert_success`, `assert_failure`, `assert_equal`, `assert_file_exists`, `assert_dir_exists`, `assert_not_exists`, `assert_is_symlink`, `assert_is_regular_file`, `assert_is_regular_dir`, `assert_link_target`, `assert_output_contains`, `assert_file_contains`.
  - `tests/helpers/sandbox.bash`: `setup_sandbox`, `teardown_sandbox`, `mock_command`.
- `tests/run_tests.sh` auto-discovers any `test_*.bash` file, so a new suite is picked up by `make test` with no registration. **`make test-runtime` lists unit suites explicitly — add yours there too**, otherwise `make test-runtime` silently skips it.
- The `TS-##` identifiers are canonical in [`wiki/07-Testing-and-CI-CD.md`](./wiki/07-Testing-and-CI-CD.md). Update that matrix when you add or change a suite. [`TEST_SCENARIOS.md`](./TEST_SCENARIOS.md) covers only manual and interactive scenarios.

---

## 6. Rules by file

- **`install.sh`** — every flag must be handled by the parser, `--dry-run` must not write anything, and any change to backup/restore must keep the manifest in sync. `-y` (and `-y --no-deps`) is the non-interactive path CI depends on.
- **`plugins.lock` / `dependencies.lock`** — SHAs and checksums change only with an intentional dependency update. Never regenerate them wholesale.
- **`wiki/`** — the GitHub Wiki is a **mirror**, not a source. `wiki-sync.yml` wipes the remote wiki and copies `wiki/*` on every push to `main` that touches `wiki/**`. Never edit a page from the GitHub Wiki UI; it is deleted on the next sync. Edit `wiki/*.md` in the repository.
- **`.config/zsh/.zshenv`** — the `PATH` array is assembled here and is deduplicated. Keep XDG defaults in the `${XDG_*:-$HOME/...}` form so user overrides win.
- **`.config/zsh/themes/`** — root must resolve to `tokyo`.

---

## 7. Known traps

| Trap | Consequence |
| :--- | :--- |
| `dev-env.zsh` defines shell functions named `git`, `gentle-shell` and `gentle-ai` | They shadow the real binaries in interactive shells. Use `command git ...` to bypass. `git init` and `gentle-shell`/`gentle-ai` refuse to run in `$HOME`; the bypasses are `GIT_ALLOW_HOME_INIT=1` and `GENTLE_ALLOW_HOME=1`. |
| `JOB_QUEUE_TMPDIR` and `ABBR_TMPDIR` are suffixed with `$UID` | Dropping the `$UID` suffix reintroduces multi-user temp collisions on shared hosts. |
| `wiki-sync.yml` does `rm -rf` on the remote wiki | A page created directly on the GitHub Wiki is lost on the next `wiki/**` push. |
| `local.zsh` is git-ignored | A new host-local setting must also be added to `local.zsh.example`, or other machines never see it. |
| `make verify` only warns on a dirty tree | Do not read a green `make verify` as "ready to commit". |
| `docs/archive/REMEDIATION_PLAN.md` is 100% completed | It is history, not a task list. Do not implement items from it. |
| The root prompt theme is pinned to `tokyo` | "Fixing" root to `clean-detailed` breaks root/user isolation. |

---

## 8. Release

1. Land the work on `main` (or merge the PR) and wait for the CI matrix to go green.
2. Create an annotated tag on the merge commit: `git tag -a vX.Y.Z -m "Release vX.Y.Z: <short summary>"`.
3. Push the tag: `git push origin vX.Y.Z`.
4. Publish it: `gh release create vX.Y.Z --title "vX.Y.Z - <title>" --notes-file <file> --verify-tag`.
5. Record the entry in [`CHANGELOG.md`](./CHANGELOG.md).

Versioning: **patch** = fix, **minor** = new user-facing behavior, **major** = breaking change. The current release is `v2.4.0`.

---

## 9. Where the detail lives

| Chapter | Topic |
| :--- | :--- |
| [01](https://github.com/Merxxotas/zsh-dotfiles/wiki/01-Architecture-and-XDG) | Directory layout, XDG compliance, startup lifecycle, root fallback |
| [02](https://github.com/Merxxotas/zsh-dotfiles/wiki/02-Installation-and-Deployment) | Installer architecture, flags, copy vs symlink, transactional backups |
| [03](https://github.com/Merxxotas/zsh-dotfiles/wiki/03-Dev-Environment-and-Tooling) | PNPM/NVM/Bun/Cargo, Pay-Respects, IntelliShell, Atuin |
| [04](https://github.com/Merxxotas/zsh-dotfiles/wiki/04-Multimedia-Suite) | `vconv`, `vdl`, `adl`, `vaudio`, `vcut`, `vgif` |
| [05](https://github.com/Merxxotas/zsh-dotfiles/wiki/05-Themes-and-Prompt-Engine) | Oh-My-Posh engine, root vs user isolation, `posh-theme` |
| [06](https://github.com/Merxxotas/zsh-dotfiles/wiki/06-Plugins-and-Keybindings) | Pinned plugins, FZF-Tab previews, shortcuts, abbreviations |
| [07](https://github.com/Merxxotas/zsh-dotfiles/wiki/07-Testing-and-CI-CD) | Offline test harness, unit/integration suites, CI matrix |
| [08](https://github.com/Merxxotas/zsh-dotfiles/wiki/08-Security-and-Supply-Chain) | Threat model, lockfiles, API keys, secret isolation |

Other entry points: [`README.md`](./README.md) for humans, [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the contribution process, [`SECURITY.md`](./SECURITY.md) for vulnerability reporting.
