<!-- markdownlint-disable MD013 -->

# Dotfiles

Dotfiles managed with [yadm](https://yadm.io/). These dotfiles have been tested
on `macOS` and `Ubuntu`.

## ⚡ Installation

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

## 🔧 Usage

### 🖥️ Alacritty

[Alacritty](https://github.com/alacritty/alacritty) is installed as the terminal
emulator.

> **[Alacritty Keymaps →](docs/alacritty.md)**

### 🐚 Shell (Zsh)

Zsh is configured with [antidote](https://github.com/mattmc3/antidote) as the
plugin manager and [Starship](https://starship.rs/) as the prompt.

#### 🔌 Zsh Plugins

- [zsh-completions](https://github.com/zsh-users/zsh-completions) — Additional
  completion definitions
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) —
  Fish-like autosuggestions
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  — Syntax highlighting at the prompt
- [zsh-vim-mode](https://github.com/softmoth/zsh-vim-mode) — Vim keybindings for
  the command line

#### 🔗 Tool Integrations

| Tool                                            | Description                             |
| ----------------------------------------------- | --------------------------------------- |
| [fzf](https://github.com/junegunn/fzf)          | Fuzzy finder (`C-r` for history search) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` (aliased to `cd`)          |
| [mise](https://github.com/jdx/mise)             | Runtime version management              |
| [Starship](https://starship.rs/)                | Cross-shell prompt                      |

#### ⌨️ Key Aliases

| Alias | Expands To                                                  |
| ----- | ----------------------------------------------------------- |
| `v`   | `nvim`                                                      |
| `lg`  | `lazygit`                                                   |
| `ly`  | `lazyyadm` (lazygit for yadm files)                         |
| `ls`  | `eza`                                                       |
| `ll`  | `eza -la --header --git --icons --changed --time-style=iso` |
| `cat` | `bat` (interactive terminals only)                          |
| `cd`  | `z` (zoxide, interactive terminals only)                    |
| `f`   | `open -a Finder ./` (macOS only)                            |

#### 🛠️ CLI Utilities

Below is a list of CLI utilities that are installed.

| Utility       | Description                                                          | Link                                                |
| ------------- | -------------------------------------------------------------------- | --------------------------------------------------- |
| `mise`        | Runtime version management (replaces pyenv/rbenv/nvm).               | [Link](https://github.com/jdx/mise)                 |
| `uv`          | Python package and project manager.                                  | [Link](https://github.com/astral-sh/uv)             |
| `starship`    | Cross-shell prompt.                                                  | [Link](https://starship.rs/)                        |
| `bat`         | A `cat` clone with syntax highlighting and Git integration.          | [Link](https://github.com/sharkdp/bat)              |
| `fd`          | A simple, fast, and user-friendly alternative to `find`.             | [Link](https://github.com/sharkdp/fd)               |
| `fzf`         | A general-purpose command-line fuzzy finder.                         | [Link](https://github.com/junegunn/fzf)             |
| `gh`          | GitHub's official CLI tool for managing repositories.                | [Link](https://cli.github.com)                      |
| `git-delta`   | A viewer for git and diff output with syntax highlighting.           | [Link](https://github.com/dandavison/delta)         |
| `lazygit`     | A simple terminal UI for git commands.                               | [Link](https://github.com/jesseduffield/lazygit)    |
| `jq`          | A lightweight and flexible command-line JSON processor.              | [Link](https://github.com/stedolan/jq)              |
| `macos-trash` | A command-line interface to the macOS trash (e.g, `trash file.txt`). | [Link](https://github.com/sindresorhus/macos-trash) |
| `ripgrep`     | A fast line-oriented search tool, like `grep` with steroids.         | [Link](https://github.com/BurntSushi/ripgrep)       |
| `tealdeer`    | More readable `man` pages (e.g., `tldr grep`)                        | [Link](https://github.com/dbrgn/tealdeer)           |
| `tmuxinator`  | Define and manage tmux session layouts via YAML.                     | [Link](https://github.com/tmuxinator/tmuxinator)    |
| `tree`        | A recursive directory listing command with tree-like output.         | [Link](http://mama.indstate.edu/users/ice/tree)     |
| `eza`         | Modern replacement for `ls`.                                         | [Link](https://github.com/eza-community/eza)        |
| `zoxide`      | A smarter `cd` command.                                              | [Link](https://github.com/ajeetdsouza/zoxide)       |

### 🪟 Tmux

[Tmux](https://github.com/tmux/tmux) is the terminal multiplexer. The prefix is
remapped to `C-a`. When connecting over [mosh](https://mosh.org/), the prefix
automatically switches back to `C-b` for compatibility with mobile clients.

> **[Tmux Keymaps →](docs/tmux.md)**

#### 🔌 Tmux Plugins

Tmux plugins installed via [TPM](https://github.com/tmux-plugins/tpm), plus
[tmuxinator](https://github.com/tmuxinator/tmuxinator) as a companion tool for
session layouts:

| Plugin                                                                  | Description                                                     |
| ----------------------------------------------------------------------- | --------------------------------------------------------------- |
| [dracula/tmux](https://github.com/dracula/tmux)                         | Status bar theme with powerline and system info                 |
| [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)        | Save and restore tmux sessions across restarts                  |
| [tmux-yank](https://github.com/tmux-plugins/tmux-yank)                  | Copy to system clipboard from tmux copy mode                    |
| [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator) | Seamless navigation between tmux panes and Vim splits           |
| [tmux-fuzzback](https://github.com/roosta/tmux-fuzzback)                | Fuzzy search scrollback buffer via fzf popup                    |
| [extrakto](https://github.com/laktak/extrakto)                          | Extract and select tokens (URLs, paths, hashes) from scrollback |
| [tmux-sessionx](https://github.com/omerxx/tmux-sessionx)                | Fuzzy session picker with zoxide and tmuxinator integration     |
| [tmuxinator](https://github.com/tmuxinator/tmuxinator)                  | Define and manage tmux session layouts via YAML                 |

### ✏️ Neovim (LazyVim)

[Neovim](https://neovim.io) is configured using
[LazyVim](https://github.com/LazyVim/LazyVim) as the base distribution. See the
[LazyVim keymaps reference](https://www.lazyvim.org/keymaps) for all default
keybindings. Only custom overrides and additions are documented below.

The `<Leader>` key is `Space`.

> **[Neovim Keymaps →](docs/neovim.md)**

#### 📦 Enabled LazyVim Extras

**AI**:
`ai.copilot`,
`ai.copilot-chat`

**Coding**:
`coding.mini-surround`,
`coding.yanky`

**DAP**:
`dap.core`

**Editor**:
`editor.aerial`,
`editor.dial`,
`editor.harpoon2`,
`editor.inc-rename`,
`editor.mini-move`,
`editor.overseer`,
`editor.telescope`

**Formatting**:
`formatting.prettier`

**Lang**:
`lang.ansible`,
`lang.docker`,
`lang.git`,
`lang.json`,
`lang.markdown`,
`lang.python`,
`lang.sql`,
`lang.tailwind`,
`lang.toml`,
`lang.typescript`,
`lang.yaml`

**Linting**:
`linting.eslint`

**Test**:
`test.core`

**UI**:
`ui.mini-indentscope`,
`ui.treesitter-context`

**Util**:
`util.dot`,
`util.mini-hipatterns`,
`util.project`

### 💡 IdeaVim (JetBrains)

[IdeaVim](https://github.com/JetBrains/ideavim) provides Vim emulation in
JetBrains IDEs. The `<Leader>` key is `Space`.

#### 🔌 IdeaVim Plugins

`easymotion`, `surround`, `commentary`, `paragraph-motion`, `nerdtree`,
`which-key`

> **[IdeaVim Keymaps →](docs/ideavim.md)**

## 🙏 Acknowledgements

In addition to all the amazing projects listed above, thanks goes out to the
following projects/individuals for providing inspiration and/or code:

- [LazyVim](https://github.com/LazyVim/LazyVim): Referenced for how to properly
  configure nvim.
- [tjdevries](https://github.com/tjdevries): Great YouTube content code samples.
