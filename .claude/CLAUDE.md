- When producing Python code, please only add docstrings in situations where the code is particular complex and nuanced. In general, the code should read like a book so docstrings should not be needed.

## Home Directory Dotfiles Management (yadm)

When working in the home directory (`/Users/salim`), use **yadm** for version control of dotfiles.

### Repository Info
- **Remote:** `origin` → `git@github.com:salimhamed/dotfiles-keep.git`
- **Base branch:** `sal/various-updates-from-mac`
- **Tracked files:** ~150 dotfiles

### Workflow Conventions
1. **Branching:** Create feature branches `sal/claude-<descriptive-name>` for changes
2. **Push policy:** Auto-push to origin after each commit
3. **Platform scope:** Only modify `##os.Darwin` file variants unless explicitly asked
4. **Safety:** Always read files before editing; stage specific files (never `yadm add -A`)

### Key Files
| Category | Files |
|----------|-------|
| Shell | `~/.zshrc##os.Darwin`, `~/.oh-my-zsh-custom/*.zsh` |
| Editor | `~/.config/nvim/`, `~/.config/lazyvim/`, `~/.vimrc` |
| Git | `~/.gitconfig`, `~/.gitconfig.local##os.Darwin,class.Personal` |
| Terminal | `~/.tmux.conf`, `~/.config/alacritty/alacritty.toml` |
| Bootstrap | `~/.config/yadm/bootstrap##os.Darwin`, `~/.Brewfile` |

### Quick Commands
```bash
yadm status              # Check state
yadm list -a             # List tracked files
yadm checkout -b <branch> # Create feature branch
yadm push -u origin HEAD # Push new branch
```