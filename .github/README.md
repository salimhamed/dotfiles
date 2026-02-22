<!-- markdownlint-disable MD013 -->

# 🗄️ Dotfiles

Dotfiles managed with [yadm](https://yadm.io/). These dotfiles have been tested
on `macOS` and `Ubuntu`.

## 📦 Installation

First, install [`yadm`](https://yadm.io/docs/install). Then, clone the
repository with `yadm` and run `bootstrap`.

```bash
# clone repository
yadm clone https://github.com/salimhamed/dotfiles.git

# set the class to either `Personal` or `Work`
yadm config local.class Personal

# bootstrap the environment
yadm bootstrap
```

## 🏃 Usage

### 🚀 Alacritty

[Alacritty](https://github.com/alacritty/alacritty) is a terminal emulator that
comes with sensible defaults and is configured with `toml` files, which can be
more easily managed with version control systems.

- `option_as_alt = "Both"` on macOS (treat Option as Alt)

#### Alacritty Keymaps

| Keybinding      | Description                                          |
| --------------- | ---------------------------------------------------- |
| `Shift+Return`  | Send `ESC` + `CR` (for Shift-Enter in terminal apps) |

### 👻 Ghostty

[Ghostty](https://ghostty.org/) is a GPU-accelerated terminal emulator.

- `macos-option-as-alt = true` (treat Option as Alt on macOS)

#### Ghostty Keymaps

| Keybinding     | Description                                          |
| -------------- | ---------------------------------------------------- |
| `Shift+Enter`  | Send `ESC` + `CR` (for Shift-Enter in terminal apps) |

### 💻 Tmux

Tmux plugins installed via [TPM](https://github.com/tmux-plugins/tpm):

| Plugin | Description |
| ------ | ----------- |
| [dracula/tmux](https://github.com/dracula/tmux) | Status bar theme with powerline and system info |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) | Save and restore tmux sessions across restarts |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank) | Copy to system clipboard from tmux copy mode (stays in copy mode after yank) |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless navigation between tmux panes and Vim splits |
| [tmux-fuzzback](https://github.com/roosta/tmux-fuzzback) | Fuzzy search scrollback buffer via fzf popup |
| [extrakto](https://github.com/laktak/extrakto) | Extract and select tokens (URLs, paths, hashes) from scrollback |

The status bar is positioned at the top. When connecting via
[mosh](https://mosh.org/), the prefix automatically switches back to `C-b` so it
doesn't conflict with nested tmux sessions.

#### Tmux Keymaps

The `<Prefix>` Keybinding has been remapped to `C-a`, replacing the default
`C-b`.

##### Tmux General Usage

| Keybinding                | Description                                              |
| ------------------------- | -------------------------------------------------------- |
| `<Prefix> [`              | Enter "Copy Mode" or "Select Mode"                       |
| `v` (copy mode)           | Begin selection (vim-style visual)                       |
| `<Prefix> C-L`            | Clear screen                                             |
| `<Prefix> c`              | Create new window                                        |
| `<Prefix> &`              | Kill current window                                      |
| `<Prefix> C-]`            | Goto next window                                         |
| `<Prefix> C-[`            | Goto previous window                                     |
| `<Prefix> 0`              | Goto 0 index window (works for other numbers)            |
| `<Prefix> f`              | Find window                                              |
| `<Prefix> w`              | List all windows                                         |
| `<Prefix> ,`              | Rename window                                            |
| `<Prefix> C-v`            | Vertical split pane                                      |
| `<Prefix> C-_`            | Horizontal split pane                                    |
| `<Prefix> S-Up`           | Resize pane 5 rows up                                    |
| `<Prefix> S-Down`         | Resize pane 5 rows down                                  |
| `<Prefix> S-Right`        | Resize pane 5 rows right                                 |
| `<Prefix> S-Left`         | Resize pane 5 rows left                                  |
| `<Prefix> z`              | Toggle zooom on current pane                             |
| `<Prefix> x`              | Kill current pane                                        |
| `<Prefix> h/j/k/l`       | Select pane (vi-style, with prefix)                      |
| `C-h`                     | Navigate panes left or send C-h to Vim (also works in copy-mode-vi) |
| `C-j`                     | Navigate panes down or send C-j to Vim (also works in copy-mode-vi) |
| `C-k`                     | Navigate panes up or send C-k to Vim (also works in copy-mode-vi) |
| `C-l`                     | Navigate panes right or send C-l to Vim (also works in copy-mode-vi) |
| `<Prefix> s`              | Show and select other tmux sessions                      |
| `<Prefix> w`              | Show and select other tmux windows in current session    |
| `<Prefix> >`              | Pane show action menu                                    |
| `<Prefix> <`              | Pane show window action menu                             |
| `<Prefix> :new -s <name>` | Create a new session, within a tmux session, with a name |
| `<Prefix> )`              | Goto next session                                        |
| `<Prefix> (`              | Goto previous session                                    |
| `<Prefix> ?`              | Fuzzy search scrollback buffer (tmux-fuzzback)           |
| `<Prefix> Tab`            | Extract and select tokens from scrollback (extrakto)     |

##### Updating Configuration and Managing Plugins

| Keybinding     | Description        |
| -------------- | ------------------ |
| `<Prefix> r`   | Reload Tmux Config |
| `<Prefix> I`   | Install plugins    |
| `<Prefix> M-u` | Uninstall plugins  |
| `<Prefix> u`   | Update plugins     |

##### Session Management with tmux-resurrect

| Keybinding     | Description     |
| -------------- | --------------- |
| `<Prefix> C-s` | Save session    |
| `<Prefix> C-r` | Restore session |

##### Nested Session Toggle

| Keybinding | Description                                             |
| ---------- | ------------------------------------------------------- |
| `F12`      | Toggle outer session off/on for nested tmux sessions    |

##### Entering Command Prompt Mode and Running Tmux Commands

Use `Prefix :` to enter Command Prompt Mode. Then type any command and press
enter. Here are some command commands.

| Command            | Description                                        |
| ------------------ | -------------------------------------------------- |
| `list-commands`    | List all available commands                        |
| `kill-server`      | Kills the currently active tmux server             |
| `list-keys`        | Show all the keymaps for the current session       |
| `respawn-pane -k`  | Restarts a pane with its initial command           |
| `swap-window -t 2` | Swap the current window with the window at index 2 |

### 🚀 Neovim (LazyVim)

[Neovim](https://neovim.io) is configured using
[LazyVim](https://github.com/LazyVim/LazyVim) as the base distribution. See the
[LazyVim keymaps reference](https://www.lazyvim.org/keymaps) for all default
keybindings. Only custom overrides and additions are documented below.

The `<Leader>` key is `Space`.

#### Enabled LazyVim Extras (31)

**AI**: `copilot`, `copilot-chat`
**Coding**: `mini-surround`, `yanky`
**DAP**: `core`
**Editor**: `aerial`, `dial`, `harpoon2`, `inc-rename`, `mini-move`, `overseer`, `telescope`
**Formatting**: `prettier`
**Linting**: `eslint`
**Lang**: `ansible`, `docker`, `git`, `json`, `markdown`, `python`, `sql`, `tailwind`, `toml`, `typescript`, `yaml`
**Test**: `core`
**UI**: `mini-indentscope`, `treesitter-context`
**Util**: `dot`, `mini-hipatterns`, `project`

#### Notable Configuration

- **Picker**: Telescope (via `vim.g.lazyvim_picker`)
- **Python LSP**: pyright + ruff
- **Flash `s`**: Disabled (restores default `s` behavior)
- **nvim-notify**: Minimal rendering, static stages
- **shfmt**: 4-space indent (`-i 4 -ci`)
- **exrc**: Enabled (`.exrc`, `.nvimrc`, `.nvim.lua` sourced per-project)
- **neo-tree**: Uses [nvim-window-picker](https://github.com/s1n7ax/nvim-window-picker) for split target selection

#### Custom Keymaps

| Key | Mode | Action |
| --- | --- | --- |
| `<S-Arrow>` | Normal | Window resize (replaces `<C-Arrow>`) |
| `<F12>` | Normal/Terminal | Toggle terminal (replaces `<C-/>`) |
| `<C-d>` / `<C-u>` | Normal | Half-page scroll + center cursor |
| `n` / `N` | Normal | Search next/prev + center + open folds |
| `<C-h/j/k/l>` | Normal | Tmux-aware split navigation |
| `<cr>` | neo-tree | Open file with window-picker target selection |
| `<leader>fyf` | Normal | Find yadm files (Telescope) |
| `<leader>fyp` | Normal | Grep yadm files (Telescope) |

### 🔧 IdeaVim (JetBrains)

[IdeaVim](https://github.com/JetBrains/ideavim) provides Vim emulation in
JetBrains IDEs. The `<Leader>` key is `Space`.

#### IdeaVim Plugins

`easymotion`, `surround`, `commentary`, `paragraph-motion`, `nerdtree`,
`which-key`

#### Navigation

| Key | Description |
| --- | --- |
| `<leader>j` | EasyMotion forward search |
| `<leader>J` | EasyMotion backward search |
| `C-h/j/k/l` | Navigate between splits |
| `S-l` / `S-h` | Next / previous tab |
| `C-d` / `C-u` | Half-page scroll + center |
| `n` / `N` | Search next/prev + center + open folds |
| `C-n` | Clear search highlight |

#### Window Management

| Key | Description |
| --- | --- |
| `S-Up/Down/Left/Right` | Stretch split in direction |
| `C-w q` | Close all editors |

#### File Explorer and Find

| Key | Description |
| --- | --- |
| `<leader>e` | Toggle NERDTree (project tool window) |
| `<leader>fe` | Search Everywhere |
| `<leader>fr` | Recent Files |
| `<leader>fc` | Find Class |
| `<leader>fa` | Search Actions |
| `<leader>ff` | Find File |
| `<leader>fs` | Find Symbol |
| `<leader>fp` | Search Within Files (Find in Path) |

#### Buffer Management

| Key | Description |
| --- | --- |
| `<leader>bd` | Delete buffer |
| `<leader>br` | Close buffers to the right |
| `<leader>bl` | Close buffers to the left |
| `<leader>ba` | Close all but current buffer |
| `<leader>bm` | Move to opposite tab group |
| `<leader>b<C-v>` | Split and move right |
| `<leader>b<C-->` | Split and move down |

#### LSP

| Key | Description |
| --- | --- |
| `gr` | Goto references (Find Usages) |
| `go` | Goto type definition |
| `gq` | Quick implementations |
| `gb` | Goto database view |

#### Folding

| Key | Description |
| --- | --- |
| `zC` | Close all folds under cursor (recursive) |
| `zO` | Open all folds under cursor (recursive) |

#### Other

| Key | Description |
| --- | --- |
| `Tab` | Accept Sweep AI autocomplete suggestion |
| `C-\` | Toggle terminal tool window |
| `C-S` | Save current buffer |
| `p` (visual) | Paste without yanking replaced text |
| `<` / `>` (visual) | Indent block and reselect |

### 🐚 Shell (Zsh)

Zsh is configured with [antidote](https://github.com/mattmc3/antidote) as the
plugin manager and [Starship](https://starship.rs/) as the prompt.

#### Zsh Plugins

- [zsh-completions](https://github.com/zsh-users/zsh-completions) — Additional
  completion definitions
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) —
  Fish-like autosuggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) —
  Syntax highlighting at the prompt
- [zsh-vim-mode](https://github.com/softmoth/zsh-vim-mode) — Vim keybindings
  for the command line

#### Tool Integrations

| Tool | Description |
| --- | --- |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder (`C-r` for history search) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` (aliased to `cd`) |
| [mise](https://github.com/jdx/mise) | Runtime version management |
| [direnv](https://direnv.net/) | Directory-scoped environment variables |
| [Starship](https://starship.rs/) | Cross-shell prompt |

#### Key Aliases

| Alias | Expands To |
| --- | --- |
| `v` | `nvim` |
| `lvim` | `NVIM_APPNAME=lazyvim nvim` |
| `nvim-kickstart` | `NVIM_APPNAME=kickstart nvim` |
| `nvim-chad` | `NVIM_APPNAME=nvchad nvim` |
| `lg` | `lazygit` |
| `ly` | `lazyyadm` (lazygit for yadm files) |
| `lazyyadm` | `lazygit --use-config-file ... --work-tree ~ --git-dir ~/.local/share/yadm/repo.git` |
| `ls` | `eza` |
| `ll` | `eza -la --header --git --icons --changed --time-style=iso` |
| `cat` | `bat` (interactive terminals only) |
| `cd` | `z` (zoxide, interactive terminals only) |
| `cp` / `mv` | `cp -iv` / `mv -iv` (interactive terminals only) |
| `mkdir` | `mkdir -pv` |
| `less` | `less -FSRXc` |
| `git-count` | `git ls-files \| xargs wc -l` (count lines in tracked files) |
| `f` | `open -a Finder ./` (macOS only) |

#### Helper Functions

| Function | Description |
| --- | --- |
| `listening_on_port <port>` | Show processes listening on a specific port |
| `listening_on_ports` | Show all processes in LISTEN state |
| `ssm <instance-id>` | Start an AWS SSM session |
| `count_lines_of_code <url>` | Clone a repo and count lines with `cloc` |
| `tclean` | Detach all other tmux clients |

### 🌿 Git

Git is configured with [delta](https://github.com/dandavison/delta) as the
pager (side-by-side diffs, Dracula theme).

#### Git Aliases

| Alias | Command |
| --- | --- |
| `co` | `checkout` |
| `ci` | `commit` |
| `st` | `status` |
| `br` | `branch` |
| `lg` | `log --oneline --decorate --all --graph` |

### 🔧 CLI Utilities

Below is a list of CLI utilities that are installed.

| Utility     | Description                                                          | Link                                                |
| ----------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| `mise`      | Runtime version management (replaces pyenv/rbenv/nvm).               | [Link](https://github.com/jdx/mise)                |
| `uv`        | Python package and project manager.                                  | [Link](https://github.com/astral-sh/uv)            |
| `direnv`    | Directory-scoped environment variables.                              | [Link](https://direnv.net/)                         |
| `starship`  | Cross-shell prompt.                                                  | [Link](https://starship.rs/)                        |
| `bat`       | A `cat` clone with syntax highlighting and Git integration.          | [Link](https://github.com/sharkdp/bat)              |
| `fd`        | A simple, fast, and user-friendly alternative to `find`.             | [Link](https://github.com/sharkdp/fd)               |
| `fzf`       | A general-purpose command-line fuzzy finder.                         | [Link](https://github.com/junegunn/fzf)             |
| `gh`        | GitHub's official CLI tool for managing repositories.                | [Link](https://cli.github.com)                      |
| `git-delta` | A viewer for git and diff output with syntax highlighting.           | [Link](https://github.com/dandavison/delta)         |
| `lazygit`   | A simple terminal UI for git commands.                               | [Link](https://github.com/jesseduffield/lazygit)    |
| `jq`        | A lightweight and flexible command-line JSON processor.              | [Link](https://github.com/stedolan/jq)              |
| `macos-trash` | A command-line interface to the macOS trash (e.g, `trash file.txt`). | [Link](https://github.com/sindresorhus/macos-trash) |
| `ripgrep`   | A fast line-oriented search tool, like `grep` with steroids.         | [Link](https://github.com/BurntSushi/ripgrep)       |
| `tealdeer`  | More readable `man` pages (e.g., `tldr grep`)                        | [Link](https://github.com/dbrgn/tealdeer)           |
| `tree`      | A recursive directory listing command with tree-like output.         | [Link](http://mama.indstate.edu/users/ice/tree)     |
| `eza`       | Modern replacement for `ls`.                                         | [Link](https://github.com/eza-community/eza)        |
| `zoxide`    | A smarter `cd` command.                                              | [Link](https://github.com/ajeetdsouza/zoxide)       |

## 📦 Acknowledgements

In addition to all the amazing projects listed above, thanks goes out to the
following projects/individuals for providing inspiration and/or code:

- [LazyVim](https://github.com/LazyVim/LazyVim): Referenced for how to properly
  configure nvim.
- [tjdevries](https://github.com/tjdevries): Great YouTube content code samples.
