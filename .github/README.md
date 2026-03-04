<!-- markdownlint-disable MD013 -->

# Dotfiles

Dotfiles managed with [yadm](https://yadm.io/). These dotfiles have been tested
on `macOS` and `Ubuntu`.

## Installation

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

## Stack

| Tool                                                               | Details                      |
| ------------------------------------------------------------------ | ---------------------------- |
| [Alacritty](https://github.com/alacritty/alacritty)                | [Details](docs/alacritty.md) |
| [Zsh](https://www.zsh.org/)                                        | [Details](docs/shell.md)     |
| [Tmux](https://github.com/tmux/tmux)                               | [Details](docs/tmux.md)      |
| [Neovim](https://neovim.io) / [LazyVim](https://www.lazyvim.org/)  | [Details](docs/neovim.md)    |
| [IdeaVim](https://github.com/JetBrains/ideavim)                    | [Details](docs/ideavim.md)   |
