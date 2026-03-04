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

## Alacritty

[Alacritty](https://github.com/alacritty/alacritty) is installed as the terminal
emulator.

> **[Alacritty Keymaps →](docs/alacritty.md)**

## Shell (Zsh)

Zsh is configured with [antidote](https://github.com/mattmc3/antidote) as the
plugin manager and [Starship](https://starship.rs/) as the prompt.

> **[Shell Details →](docs/shell.md)**

## Tmux

[Tmux](https://github.com/tmux/tmux) prefix is remapped to `C-a`. The status bar
shows the ⚡ symbol when the prefix key is active. Use `<Prefix> m` to
toggle mobile mode, which switches the prefix to `C-b` (so shortcuts work
correctly with mobile SSH/Mosh clients), hides status indicators, and shows a
📱 badge.

> **[Tmux Details →](docs/tmux.md)**

## Neovim (LazyVim)

[Neovim](https://neovim.io) is configured using
[LazyVim](https://github.com/LazyVim/LazyVim) as the base distribution. See the
[LazyVim keymaps reference](https://www.lazyvim.org/keymaps) for all default
keybindings. The `<Leader>` key is `Space`.

> **[Neovim Keymaps →](docs/neovim.md)**

## IdeaVim (JetBrains)

[IdeaVim](https://github.com/JetBrains/ideavim) provides Vim emulation in
JetBrains IDEs. The `<Leader>` key is `Space`.

> **[IdeaVim Details →](docs/ideavim.md)**
