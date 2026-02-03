---
description: Load dotfiles management context for yadm work
allowed-tools: Read
---

## Home Directory Dotfiles Management (yadm)

When working in the home directory (`/Users/salim`), use **yadm** for version
control of dotfiles.

### Repository Context

- **Primary remote:** `origin` → `git@github.com:salimhamed/dotfiles.git`
- **Base branch:** `sal/various-updates-from-mac`
- **Tracked files:** 150 files
- **Platform:** macOS (Darwin) with class=Personal
- **yadm version:** 3.5.0

---

### Workflow Conventions

#### 1. Branch Strategy

- **Create feature branches** for each set of changes:
  `sal/claude-<descriptive-name>`
- Branch from `sal/various-updates-from-mac` (current working branch)
- Examples:
  - `sal/claude-nvim-config-update`
  - `sal/claude-zsh-aliases`
  - `sal/claude-tmux-keybindings`

#### 2. Commit & Push Policy

- **Auto-push after commit** to keep remote in sync
- GPG signing is enabled (commits will be signed automatically)
- Use descriptive commit messages following existing style

#### 3. Platform Scope

- **Darwin (macOS) only** unless explicitly requested otherwise
- When editing alternate files, only modify `##os.Darwin` variants
- Will note when Ubuntu variants might need corresponding updates

---

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

| File                 | Purpose               |
| -------------------- | --------------------- |
| `~/.config/nvim/`    | Primary Neovim config |
| `~/.config/lazyvim/` | LazyVim distribution  |
| `~/.vimrc`           | Legacy Vim config     |
| `~/.ideavimrc`       | JetBrains IdeaVim     |

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
yadm checkout -b sal/claude-<feature>
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
2. **Stage specific files** - Avoid `yadm add -A` in home directory
3. **Verify changes** - Run `yadm diff --staged` before committing
4. **Test changes** - Source files or restart shell to verify
5. **Keep commits atomic** - One logical change per commit

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

---

### Initial Setup Actions

Before first modifications, I will:

1. **Verify clean state:** `yadm status` to ensure no uncommitted changes
2. **Confirm remote access:** `yadm remote -v` to verify push capability
3. **Note current branch:** Track base branch for feature branching
