---
description: Load dotfiles management context for yadm work
disable-model-invocation: true
allowed-tools: Read
---

## Home Directory Dotfiles Management (yadm)

The execution of this skill indicates you're working in the user's home
directory and using **yadm** for version control and management of dotfiles.

### Repository Context

- **Primary remote:** `origin` → `git@github.com:salimhamed/dotfiles.git`
- **Base branch:** `main`
- **yadm version:** 3.5.0

---

### Workflow Conventions

#### 1. Branch Strategy

- **Create feature branches** for each set of changes if a feature branch does
  not already exist. Always ask before creating a new branch.
- Feature branches should be created from the default `main` branch
- Feature branch names should follow the naming convention:
  `claude/<descriptive-name>`
- Examples:
  - `claude/nvim-config-update`
  - `claude/zsh-aliases`
  - `claude/tmux-keybindings`

#### 2. Commit & Push Policy

- **Auto-push after commit** to keep remote in sync
- GPG signing is enabled (commits will be signed automatically)
- Use concise commit messages that are no more than one line of text

#### 3. Platform Scope

- Changes should target **Darwin (macOS) only** unless explicitly requested
  otherwise
- When editing alternate files, only modify `##os.Darwin` variants, unless
  explicitly requested otherwise

---

### Zsh Code Conventions

You might be asked to modify `zsh` code. When doing so, use a function-specific
prefix for all local variables to avoid conflicts with shell builtins,
environment variables, and other functions.

**Avoid these generic variable names:**

- `path` - conflicts with `$PATH`
- `name` - common collision
- `status` - conflicts with `$?` semantics
- `line`, `count`, `match`, `result`, `output`
- `default`, `root`, `dir`, `file`
- Single-letter variables: `d`, `f`, `n`, `i`

**Pattern:** `<prefix>_<descriptive_name>`

Here's an example function following this convention:

```zsh
wt_example() {
    local wt_branch wt_path wt_status
    wt_branch=$(git branch --show-current)
    wt_path=$(git rev-parse --show-toplevel)
    # ...
}
```

### Key Files Reference

#### Shell Configuration

| File                                          | Purpose                      |
| --------------------------------------------- | ---------------------------- |
| `~/.zshrc##os.Darwin`                         | Main zsh config              |
| `~/.zprofile##os.Darwin`                      | Login shell profile          |
| `~/.oh-my-zsh-custom/01_alias.zsh`            | Command aliases              |
| `~/.oh-my-zsh-custom/06_helper_functions.zsh` | Helper functions             |
| `~/.profile`                                  | POSIX shell profile (shared) |

#### Editor Configuration

| File                 | Purpose                                            |
| -------------------- | -------------------------------------------------- |
| `~/.config/lazyvim/` | LazyVim distribution (primary terinal text editor) |
| `~/.ideavimrc`       | JetBrains IdeaVim (primary IDE)                    |
| `~/.config/nvim/`    | Custom Neovim config (legacy)                      |
| `~/.vimrc`           | Vim config (legacy)                                |

#### Git & Tools

| File                                           | Purpose             |
| ---------------------------------------------- | ------------------- |
| `~/.gitconfig`                                 | Main git config     |
| `~/.gitconfig.local##os.Darwin,class.Personal` | Local git overrides |
| `~/.tmux.conf`                                 | Tmux configuration  |
| `~/.config/alacritty/alacritty.toml`           | Terminal config     |
| `~/.config/starship/starship.toml`             | Prompt config       |

#### Bootstrap & Packages

| File                                  | Purpose            |
| ------------------------------------- | ------------------ |
| `~/.config/yadm/bootstrap##os.Darwin` | macOS setup script |
| `~/.Brewfile`                         | Homebrew packages  |

---

### Standard Operations

#### Before Making Changes

```bash
yadm status                    # Check current state
yadm diff                      # Review any uncommitted changes
yadm branch -a                 # Verify branch context
```

#### Creating a Feature Branch

```bash
yadm checkout -b claude/<feature-description>
```

#### After Modifications

```bash
yadm add <files>               # Stage specific files
yadm status                    # Verify staged changes
yadm commit -m "description"   # Commit (auto-signed)
yadm push -u origin HEAD       # Push and set upstream
```

#### Viewing Tracked Files

```bash
yadm list -a                   # All tracked files
yadm list -a | grep <pattern>  # Filter tracked files
```

---

### Safety Practices

1. **Always read before editing** - Use Read tool before making modifications
2. **Stage specific files** - Never run `yadm add -A` in home directory
3. **Verify changes** - Run `yadm diff --staged` before committing
4. **Keep commits atomic** - One logical change per commit

---

### Verification Methods

#### Shell Changes

```bash
source ~/.zshrc                # Reload zsh config
# Or open new terminal tab
```

#### Neovim Changes

```bash
nvim --headless +checkhealth +qa  # Check nvim health
nvim -c "echo 'Config loaded'" -c qa  # Quick load test
```

#### Git Config Changes

```bash
git config --list              # Verify effective config
```

#### Bootstrap Changes

```bash
# Dry-run review only - don't execute without explicit request
bash -n ~/.config/yadm/bootstrap  # Syntax check
```

---

### Quick Commands

| Task                | Command                      |
| ------------------- | ---------------------------- |
| Check status        | `yadm status`                |
| List tracked files  | `yadm list -a`               |
| Show recent history | `yadm log --oneline -10`     |
| View remotes        | `yadm remote -v`             |
| Show current branch | `yadm branch --show-current` |
| Diff uncommitted    | `yadm diff`                  |
| Push current branch | `yadm push`                  |
