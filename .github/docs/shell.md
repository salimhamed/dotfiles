<!-- markdownlint-disable MD013 -->

# 🐚 Shell (Zsh)

[Back to README](../README.md)

## Zsh Plugins

| Plugin                                                                          | Description                          |
| ------------------------------------------------------------------------------- | ------------------------------------ |
| [zsh-completions](https://github.com/zsh-users/zsh-completions)                | Additional completion definitions    |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)         | Fish-like autosuggestions            |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | Syntax highlighting at the prompt    |
| [zsh-vim-mode](https://github.com/softmoth/zsh-vim-mode)                       | Vim keybindings for the command line |

## Tool Integrations

| Tool                                            | Description                             |
| ----------------------------------------------- | --------------------------------------- |
| [fzf](https://github.com/junegunn/fzf)          | Fuzzy finder (`C-r` for history search) |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter `cd` (aliased to `cd`)          |
| [mise](https://github.com/jdx/mise)             | Runtime version management              |
| [Starship](https://starship.rs/)                | Cross-shell prompt                      |

## Key Aliases

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

## CLI Utilities

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
