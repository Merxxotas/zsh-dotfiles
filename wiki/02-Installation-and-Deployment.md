# 02 - Installation and Deployment

The suite includes an intelligent, idempotent installer (`install.sh`) supporting interactive, unattended, copy, and symlink deployment modes across 8+ Linux distributions and macOS.

---

## Deployment Modes

### 1. Standard Copy Deployment (Recommended for Production / Servers)
Copies all configuration files directly to `~/.config/zsh/`.
```bash
./install.sh
```

### 2. Symlink Deployment (Recommended for Dotfiles Developers)
Creates granular, file-by-file symbolic links from the repository to `~/.config/zsh/`. Any edits in the repository immediately reflect in the active shell.
```bash
./install.sh --mode symlink
# or shortcut:
./install.sh -s
```

### 3. Non-Interactive Unattended Deployment (CI / Containers)
Skips all confirmation prompts and dependency package installations:
```bash
./install.sh -y --no-deps
```

### 4. Dry-Run Mode
Inspects the installation plan and target destinations without writing to disk:
```bash
./install.sh --dry-run
```

---

## Automated Backup and Rollback

Every deployment automatically takes a complete backup snapshot of any existing configuration before making changes:

* Backups are stored in `~/.local/state/zsh/backups/backup_<TIMESTAMP>`
* List all snapshots:
  ```bash
  ./install.sh --list-backups
  ```
* Restore a specific snapshot:
  ```bash
  ./install.sh --restore <backup_id>
  ```

---

## Post-Installation Verification

To verify that the installation succeeded and all symlinks/configurations are valid:
```bash
make verify
```
