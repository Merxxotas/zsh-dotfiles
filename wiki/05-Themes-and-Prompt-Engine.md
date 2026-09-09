# 05 - Themes and Prompt Engine

Prompt rendering is powered by **Oh-My-Posh** with a resilient dual-theme architecture and the `posh-theme` CLI manager.

---

## Dual Theme Isolation

Security and operational context require clear distinction between standard user sessions and elevated root sessions:

| Context | Theme | Characteristics |
| :--- | :--- | :--- |
| **Standard User** | `clean-detailed.omp.json` | Git status, execution time, path hierarchy. Transient prompt disabled to eliminate layout shifts. |
| **Root (Superuser)** | `tokyo.omp.json` | High-visibility warning cues, system RAM and privilege state. |

---

## Interactive Theme Manager (`posh-theme`)

Switch, download, and persist from 150+ official themes:

### Interactive FZF Mode
```bash
posh-theme
```
Opens an interactive fuzzy-finder menu populated with local themes and the official Oh-My-Posh theme registry.

### Direct Activation
```bash
posh-theme tokyo
posh-theme if_tea
posh-theme clean-detailed
posh-theme catppuccin
```

### Persistence
The selected theme name is saved to `$XDG_STATE_HOME/zsh/current_theme`. When opening a new terminal tab or shell session, the active theme is automatically restored.
