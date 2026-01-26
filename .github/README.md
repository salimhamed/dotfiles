<!-- markdownlint-disable MD013 -->

# 🗄️ Dotfiles

Dotfiles managed with [yadm](https://yadm.io/). These dotfiles have been tested
on `macos`. The plan is to eventually test and support severael `linux`
distributions as well. This detailed README helps me remember the setup :joy:

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
comes with sensible defaults and is configured with `yaml` files, which can be
more easily managed with version control systems.

#### Alacritty Keymaps

| Keybinding  | Description                                                                                  |
| ----------- | -------------------------------------------------------------------------------------------- |
| `C-S-Space` | Enter [Vi Mode](https://github.com/alacritty/alacritty/blob/master/docs/features.md#vi-mode) |

### 💻 Tmux

Tmux is used as a terminal multiplexer to manage multiple terminal sessions,
split screens, and easily switch between them. The
[dracula/tmux](https://github.com/dracula/tmux) plugin is installed for a better
status bar and dark mode. The
[tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect) plugin is
installed to save and restore tmux sessions after system restart.

#### Tmux Keymaps

The `<Prefix>` Keybinding has been remapped to `C-a`, replacing the default
`C-b`.

##### Tmux General Usage

| Keybinding                | Description                                              |
| ------------------------- | -------------------------------------------------------- |
| `<Prefix> [`              | Enter "Copy Mode" or "Select Mode"                       |
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
| `C-h`                     | Navigate panes left or send C-h to Vim                   |
| `C-j`                     | Navigate panes down or send C-j to Vim                   |
| `C-k`                     | Navigate panes up or send C-k to Vim                     |
| `C-l`                     | Navigate panes right or send C-l to Vim                  |
| `<Prefix> s`              | Show and select other tmux sessions                      |
| `<Prefix> w`              | Show and select other tmux windows in current session    |
| `<Prefix> >`              | Pane show action menu                                    |
| `<Prefix> <`              | Pane show window action menu                             |
| `<Prefix> :new -s <name>` | Create a new session, within a tmux session, with a name |
| `<Prefix> )`              | Goto next session                                        |
| `<Prefix> (`              | Goto previous session                                    |

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
| `<Prefix> C-r` | Restory session |

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

### 🚀 Neovim

[Neovim](https://neovim.io) is a extensible, fast, and powerful text editor that
extends the capabilities of Vim. The coding editing experience configured in
these dotfiles is specifically optimized for Python, JavaScript/TypeScript,
React (`jsx`), and lua, but should be easily extendable to other languages as
well.

#### Nvim Keymaps

The `<Leader>` key has been remapped to `" "` (i.e., space).

##### Using the Jumplist

| Keybinding | Description                    |
| ---------- | ------------------------------ |
| `C-o`      | Travel backwards through jumps |
| `C-i`      | Travel forwards through jumps  |
| `:jumps`   | View the jumplist              |

##### Window Management and Navigation

| Keybinding | Description                                      |
| ---------- | ------------------------------------------------ |
| `S-Right`  | Increase window width                            |
| `S-Left`   | Decrease window width                            |
| `S-Up`     | Increase window height                           |
| `S-Down`   | Decrease window height                           |
| `C-w =`    | Equalize the width and height of visible windows |
| `C-w _`    | Maximize the current window's height             |
| `C-w \|`   | Maximize the current window's width              |
| `C-w q`    | Close the current window                         |
| `C-h`      | Navigate window left or send C-h to tmux         |
| `C-j`      | Navigate window down or send C-j to tmux         |
| `C-k`      | Navigate window up or send C-k to tmux           |
| `C-l`      | Navigate window right or send C-l to tmux        |

##### Buffer Management and Navigation

_Use `<Leader>b` to activate `WhichKey` help._

| Keybinding       | Description                     |
| ---------------- | ------------------------------- |
| `S-l`            | Switch to buffer to the right   |
| `S-h`            | Switch to buffer to the left    |
| `C-^`            | Switch to alternate file        |
| `<Leader>b<C-v>` | Vertical split current buffer   |
| `<Leader>b<C-_>` | Horizontal split current buffer |
| `<Leader>bd`     | Delete buffer                   |
| `<Leader>bp`     | Pin buffer                      |
| `<Leader>ba`     | Close all bug current buffer    |
| `<Leader>bl`     | Close buffers to the left       |
| `<Leader>br`     | Close buffers to the right      |

##### Harpoon Navigation

| Keybinding   | Description                |
| ------------ | -------------------------- |
| `<Leader>hh` | Harpoon a file             |
| `<Leader>hv` | View Harpoon list          |
| `<Leader>hn` | Next Harpooned file        |
| `<Leader>hp` | Previous Harpooned file    |
| `<Leader>h1` | Open first Harpooned file  |
| `<Leader>h2` | Open second Harpooned file |
| `<Leader>h3` | Open third Harpooned file  |
| `<Leader>h4` | Open fourth Harpooned file |
| `<Leader>h5` | Open fifth Harpooned file  |

##### Markdown Preview

| Keybinding   | Description            |
| ------------ | ---------------------- |
| `<Leader>mp` | Start markdown preview |
| `<Leader>ms` | Stop markdown preview  |

##### Saving Sessions

| Keybinding   | Description                           |
| ------------ | ------------------------------------- |
| `<Leader>qs` | Restore session for current directory |
| `<Leader>ql` | Restore last session                  |
| `<Leader>qd` | Do not save current session           |

See [folke/persistence.nvim](https://github.com/folke/persistence.nvim) for more
details.

##### Neotree (File Explorer)

| Keybinding                 | Description                                         |
| -------------------------- | --------------------------------------------------- |
| `<Leader>e`                | Toggle Neotree                                      |
| `<C-v>`                    | (Within Neotree) Open file in vsplit                |
| `<C-_>`                    | (Within Neotree) Open file in split                 |
| `o` or `<CR>` or `<Right>` | (Within Neotree) Toggle directory node or open file |
| `Left`                     | (Within Neotree) Close directory node               |
| `y`                        | (Within Neotree) Copy relative path                 |
| `Y`                        | (Within Neotree) Copy absolute path                 |

##### Telescope (Search)

| Keybinding  | Description                            |
| ----------- | -------------------------------------- |
| `<Leader>f` | See "Which Key" options for searches   |
| `<C-v>`     | (Within Telescope) Open file in vsplit |
| `<C-_>`     | (Within Telescope) Open file in split  |

##### Surround

| Keybinding         | Description                                 |
| ------------------ | ------------------------------------------- |
| `ys<motion><char>` | Create a surrounding (i.e., "you surround") |
| `cs<char><char>`   | Change a surrounding. For example, `cs'"`   |
| `ds<char>`         | Delete a surrounding. For example, `ds"`    |

Examples:

```text
yssf - Surround sentence with a function
yswf - Surround word with a function
ysst - Surround sentence with a tag
yswt - Surround word with a tag
```

##### Toggle Terminal

[toggleterm.nvim](https://github.com/akinsho/toggleterm.nvim) is used to manage
various terminals within Neovim.

| Keybinding   | Description                                 |
| ------------ | ------------------------------------------- |
| `C-\`        | Toggle Terminal Open/Close                  |
| `<Leader>gl` | Toggle Terminal with lazygit                |
| `<Leader>gy` | Toggle Terminal with lazygit for yadm files |

##### Hop for Navigation

[hop.nvim](https://github.com/smoka7/hop.nvim) is used to quickly and easily
"hop" around a buffer.

| Keybinding  | Description                               |
| ----------- | ----------------------------------------- |
| `<Leader>j` | Jump forward to a location in the buffer  |
| `<Leader>J` | Jump backward to a location in the buffer |

##### Comments

| Keybinding          | Description                                                                        |
| ------------------- | ---------------------------------------------------------------------------------- |
| `gcc`               | Comment out a line                                                                 |
| `gc` in visual mode | Comment out selection                                                              |
| `gc` + motion       | Comment out using the target of a motion (e.g., `gcap` to comment out a paragraph) |

##### Misc Vim Tricks

- `<C-f>` while in command mode will open a window with command line history.
  Close this window with `<C-c>`.
- `<C-w>x` will swap windows.
- `:messages` will show you messages that appeared during startup.

### 🔧 CLI Utilities

Below is a list of CLI utilities that are installed.

| Utility       | Description                                                          | Link                                                |
| ------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| `pyenv`       | Python version management.                                           | [Link](https://github.com/pyenv/pyenv)              |
| `rbenv`       | Ruby version management.                                             | [Link](https://github.com/rbenv/rbenv)              |
| `nvm`         | Node version management.                                             | [Link](https://github.com/nvm-sh/nvm)               |
| `bat`         | A `cat` clone with syntax highlighting and Git integration.          | [Link](https://github.com/sharkdp/bat)              |
| `fd`          | A simple, fast, and user-friendly alternative to `find`.             | [Link](https://github.com/sharkdp/fd)               |
| `fzd`         | A general-purpose command-line fuzzy finder.                         | [Link](https://github.com/junegunn/fzf)             |
| `gh`          | GitHub's official CLI tool for managing repositories.                | [Link](https://cli.github.com)                      |
| `git-delta`   | A viewer for git and diff output with syntax highlighting.           | [Link](https://github.com/dandavison/delta)         |
| `lazygit`     | A simple terminal UI for git commands.                               | [Link](https://github.com/jesseduffield/lazygit)    |
| `jq`          | A lightweight and flexible command-line JSON processor.              | [Link](https://github.com/stedolan/jq)              |
| `macos-trash` | A command-line interface to the macOS trash (e.g, `trash file.txt`). | [Link](https://github.com/sindresorhus/macos-trash) |
| `ripgrep`     | A fast line-oriented search tool, like `grep` with steroids.         | [Link](https://github.com/BurntSushi/ripgrep)       |
| `tealdeer`    | More readable `man` pages (e.g., `tldr grep`)                        | [Link](https://github.com/dbrgn/tealdeer)           |
| `tree`        | A recursive directory listing command with tree-like output.         | [Link](http://mama.indstate.edu/users/ice/tree)     |
| `eza`         | Modern replacement for `ls`.                                         | [Link](https://github.com/eza-community/eza)        |
| `zoxide`      | A smarter `cd` command.                                              | [Link](https://github.com/ajeetdsouza/zoxide)       |

### 🔧 Terminal Keymaps

| Utility | Description                                |
| ------- | ------------------------------------------ |
| `z`     | `cd` to a path using `zoxide`              |
| `C-r`   | Use `fzd` to search through prior commands |

### 🌳 Git Worktree Commands

| Command                               | Description                                          |
| ------------------------------------- | ---------------------------------------------------- |
| `wt [partial]`                        | Fuzzy worktree picker (tmux: switch window, else cd) |
| `wt-new <branch> [base] [--existing]` | Create new worktree from base branch                 |
| `wt-here`                             | Show current worktree context (branch, status, PR)   |
| `wt-status`                           | Dashboard of all worktrees with PR state             |
| `wt-done [branch]`                    | Clean up merged worktree (verifies PR merged)        |
| `wt-list`                             | List worktrees with dirty status                     |
| `wt-cleanup`                          | Prune stale worktrees, show merged branches          |

### 🐍 Pycharm (JetBrains) Keymaps

This repository contains a .ideavimrc file for configuring JetBrains IDEs, such
as PyCharm, with Neovim-like keybindings via
[ideavim](https://github.com/JetBrains/ideavim). The keymaps below are
JetBrains-specific and provided here for my own reference.

| Utility   | Description                                                           |
| --------- | --------------------------------------------------------------------- |
| `S-Alt-]` | Go to next editor tab (works for switching between terminal tabs)     |
| `S-Alt-[` | Go to previous editor tab (works for switching between terminal tabs) |

## 📦 Acknowledgements

In addition to all the amazing projects listed above, thanks goes out to the
following projects/individuals for providing inspiration and/or code:

- [LazyVim](https://github.com/LazyVim/LazyVim): Referenced for how to properly
  configure nvim.
- [tjdevries](https://github.com/tjdevries): Great YouTube content code samples.
