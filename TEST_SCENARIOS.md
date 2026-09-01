# Verification and Test Scenarios

Technical verification suite for validating features and functionality of the ZSH Dotfiles configuration.

---

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
   - Command: `cat ~/.config/zsh/current_theme`
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

### Scenario 6: Atuin History and TUI Exploration
*Objective: Validate shell history retrieval and interactive search.*

1. Press `Ctrl + R` or `Up Arrow`.
2. Acceptance Criteria: Atuin interactive TUI opens, displaying execution history, duration, exit code, and timestamps.
3. Press `Tab` inside Atuin to toggle filter modes (Global, Host, Directory, Session).

---

### Scenario 7: Autopair Execution
*Objective: Validate automatic matching and deletion of paired delimiters.*

1. Type `"` -> Line buffer contains `""` with cursor positioned between quotes.
2. Type internal text and type `"` again -> Cursor jumps over the closing quote.
3. With cursor between empty delimiters `""` or `()`, press `Backspace` -> Both characters are removed.

---

### Scenario 8: Vi-Mode and Cursor States
*Objective: Validate modal editing and cursor geometry.*

1. Type in command buffer -> Cursor is displayed as a vertical beam (`|`).
2. Press `Esc` -> Cursor switches to solid block (`█`).
3. Press `b`, `w`, `dd` to perform standard Vi movements/edits.
4. Press `i` -> Cursor returns to vertical beam (`|`).

---

### Scenario 9: Universal Helpers (`take` and `extract`)
*Objective: Verify single-file and batch multi-archive extraction.*

1. **Directory traversal (`take`)**:
   - Command: `take /tmp/test_dir/nested`
   - Acceptance Criteria: Directory hierarchy is created and current working directory switches to `/tmp/test_dir/nested`.
2. **Single Archive Extraction (`extract`)**:
   - Command: `extract archive.tar.gz`
   - Acceptance Criteria: Archive is extracted using appropriate binary without format-specific flags.
3. **Batch Multi-Archive Extraction (e.g. Google Drive Split ZIPs)**:
   - Command: `extract *.zip` or `extract part1.zip part2.zip part3.tar.gz`
   - Acceptance Criteria: Iterates through all provided archives, extracts each in sequence, and outputs summary report: `[OK] Extracted N archive(s)`.

---

### Scenario 10: Fuzzy File Finders
*Objective: Validate FZF integration.*

1. Press `Ctrl + F` -> Launches file search excluding hidden files with bat preview.
2. Press `Ctrl + T` -> Launches comprehensive file search with bat preview.

---

### Scenario 11: Plugin Updates
*Objective: Verify parallel Git plugin update mechanism.*

1. Command: `zplugin-update`
2. Acceptance Criteria: All Git repositories located in `~/.config/zsh/plugins/` are pulled using `--ff-only`.
