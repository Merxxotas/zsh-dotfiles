# 07 - Testing and CI/CD

Quality assurance is maintained through offline unit tests, integration test suites, and an extensive multi-distribution CI matrix.

---

## Local Verification Commands

```bash
# Run full verification suite (lint, syntax, tests, clean state)
make verify

# Run automated unit and integration tests
make test

# Run installer integration tests only
make test-installer

# Run syntax and security linting
make lint
```

---

## Test Suites Matrix

| Suite | File | Targets | Coverage |
| :--- | :--- | :--- | :--- |
| **TS-01** | `test_installer.bash` | `install.sh` | Copy, symlink, transitions, backups, dry-run |
| **TS-02** | `test_media.bash` | `media.zsh` | `vdl` parser, quality constraints, error handling |
| **TS-03** | `test_prompt.bash` | `prompt.zsh` | Theme sanitization, JSON safety, state persistence |
| **TS-04** | `test_env.bash` | `.zshenv` | XDG variables, PATH deduplication, PNPM bin paths |
| **TS-05** | `test_helpers.bash` | `helpers.zsh` | `take` and `extract` batch & multi-part extraction error handling |
| **TS-06** | `test_plugins.bash` | `plugins.zsh` | Offline startup verification, commit SHA lock check |

---

## GitHub Actions CI Matrix

The repository runs automated workflows on every push to `main`:

* **`lint.yml`**: Static analysis with ShellCheck, Python JSON linting, and security pattern audits.
* **`unit.yml`**: Offline execution of the full unit and integration test suite on Ubuntu and macOS.
* **`ci-debian-ubuntu.yml`**: Tests installation on Ubuntu 24.04, Ubuntu 22.04, Debian 12, Debian 11.
* **`ci-arch-fedora-suse.yml`**: Tests on Arch Linux, Fedora, and openSUSE Leap.
* **`ci-enterprise-alpine-gentoo.yml`**: Tests on Rocky Linux 9, AlmaLinux 9, and Alpine Linux.
