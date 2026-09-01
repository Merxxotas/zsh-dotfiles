# Verification and Test Scenarios

Technical verification suite for validating features and functionality of the ZSH Dotfiles configuration.

---

## Automated Test Suite Matrix

Run all offline automated tests with:

```bash
make test
```

| ID | Suite | Target | Status | Coverage |
| :--- | :--- | :--- | :---: | :--- |
| **TS-01** | `test_installer.bash` | `install.sh` | **Automated** | Copy, symlink, transitions, backups, dry-run, unknown arguments |
| **TS-02** | `test_media.bash` | `media.zsh` | **Automated** | `vdl` parser, strict quality bounds, error codes on missing inputs |
| **TS-03** | `test_prompt.bash` | `prompt.zsh` | **Automated** | Theme sanitization, JSON security, XDG cache persistence |
| **TS-04** | `test_env.bash` | `.zshenv` | **Automated** | XDG defaults preservation, PATH deduplication, GPG_TTY safety |
| **TS-05** | `test_helpers.bash` | `helpers.zsh` | **Automated** | `take` argument validation, `extract` batch error codes |
| **TS-06** | `test_plugins.bash` | `plugins.zsh` | **Automated** | Zero network during startup, `plugins.lock` integrity |

---

## Interactive & Visual Scenarios

### Scenario 1: FZF-Tab Interactive Completion Previews
*Objective: Verify contextual preview rendering upon Tab trigger.*

1. **Process Inspection**:
   - Command: `kill ` (with trailing space) + press `Tab`.
   - Acceptance Criteria: Interactive FZF popup appears containing active processes with PID, CPU, Memory, and command line.
2. **Directory Tree Inspection**:
   - Command: `cd ` + press `Tab`.
   - Acceptance Criteria: Interactive popup displays real-time directory tree structure generated via `eza`.
3. **Syntax Highlighted File Preview**:
   - Command: `bat ` or `nvim ` + press `Tab`.
   - Acceptance Criteria: Preview pane renders file contents with line numbering and syntax highlighting.
4. **Environment Variable Inspection**:
   - Command: `echo $` + press `Tab`.
   - Acceptance Criteria: Values of environment variables are displayed in the preview pane.
5. **Git Branch and Log Preview**:
   - Command (inside a Git repository): `git checkout ` + press `Tab`.
   - Acceptance Criteria: Commit logs and graph for available branches are rendered in the preview pane.

---

### Scenario 2: Oh-My-Posh Theme Management (`posh-theme`)
*Objective: Verify dynamic theme switching, remote downloads, and persistence.*

1. **Interactive Selection**:
   - Command: `posh-theme`
   - Acceptance Criteria: FZF selection menu displays available local and popular official themes (150+ themes).
2. **Direct Activation**:
   - Command: `posh-theme if_tea`
   - Acceptance Criteria: Theme is loaded from cache or downloaded, stripped of transient prompts, and applied immediately.
3. **Persistence Verification**:
   - Command: `cat $XDG_STATE_HOME/zsh/current_theme`
   - Acceptance Criteria: File contains `if_tea` and persists across new shell sessions.
4. **Reset to Default**:
   - Command: `posh-theme clean-detailed`

---

### Scenario 3: Real-Time Abbreviations (`zsh-abbr`)
*Objective: Verify expansion behavior and explicit history persistence.*

1. Type `gs` and press `Space` -> Expands to `git status -s`.
2. Type `lg` and press `Space` -> Expands to `lazygit`.
3. Type `gco` and press `Space` -> Expands to `git checkout`.
4. Type `gaa` and press `Space` -> Expands to `git add --all`.
5. Type `pac` and press `Space` -> Expands to `sudo pacman -S`.
6. Type `sc` and press `Space` -> Expands to `sudo systemctl`.

---

### Scenario 4: Magic Sudo (`Alt+S`)
*Objective: Validate prefixing and removing sudo dynamically.*

1. Type: `pacman -Syu` or `apt update` (do not press Enter).
2. Press `Alt + S`.
3. Acceptance Criteria: Buffer is transformed to `sudo pacman -Syu`. Pressing `Alt + S` again removes the `sudo ` prefix.

---

### Scenario 5: Didactic Alias Reminder (`zsh-you-should-use`)
*Objective: Verify suggestions when explicit long commands are typed.*

1. Inside a Git repository, type: `git status -s` and press `Enter`.
2. Acceptance Criteria: Execution completes and an inline reminder is printed: `Found existing alias: 'gs'`.

---

### Scenario 6: Vi-Mode Status Bar Integration
*Objective: Verify real-time mode transitions and cursor indicators.*

1. Open a new Zsh terminal.
2. Press `Escape` -> Cursor shape transforms to Block / command mode.
3. Press `i` or `a` -> Cursor shape transforms to Line / insert mode.
