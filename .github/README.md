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

- 🖥️ **[Alacritty](docs/alacritty.md)** - Terminal emulator
- 🐚 **[Zsh](docs/shell.md)** - Shell with antidote and Starship
- 💻 **[Tmux](docs/tmux.md)** - Terminal multiplexer
- 🚀 **[Neovim](docs/neovim.md)** - Terminal editor via LazyVim
- 🔧 **[IdeaVim](docs/ideavim.md)** - Vim emulation in JetBrains
