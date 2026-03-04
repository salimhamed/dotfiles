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

- 🖥️ **[Alacritty](https://github.com/alacritty/alacritty)** — Terminal emulator · [Details](docs/alacritty.md)
- 🐚 **[Zsh](https://www.zsh.org/)** — Shell with antidote and Starship · [Details](docs/shell.md)
- 💻 **[Tmux](https://github.com/tmux/tmux)** — Terminal multiplexer · [Details](docs/tmux.md)
- 🚀 **[Neovim](https://neovim.io)** — Terminal editor via LazyVim · [Details](docs/neovim.md)
- 🔧 **[IdeaVim](https://github.com/JetBrains/ideavim)** — Vim emulation in JetBrains · [Details](docs/ideavim.md)
