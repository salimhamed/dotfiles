<!-- markdownlint-disable MD013 -->

# 🚀 Neovim Keymaps

[Back to README](../README.md)

The `<Leader>` key is `Space`. For all default LazyVim keybindings, see the
[LazyVim keymaps reference](https://www.lazyvim.org/keymaps).

## Custom Keybindings

| Key                | Mode            | Description                            |
| ------------------ | --------------- | -------------------------------------- |
| `<S-Up>`           | Normal          | Increase window height                 |
| `<S-Down>`         | Normal          | Decrease window height                 |
| `<S-Left>`         | Normal          | Decrease window width                  |
| `<S-Right>`        | Normal          | Increase window width                  |
| `<C-d>`            | Normal          | Half-page scroll down + center cursor  |
| `<C-u>`            | Normal          | Half-page scroll up + center cursor    |
| `n`                | Normal          | Search next + center + open folds      |
| `N`                | Normal          | Search prev + center + open folds      |
| `<F12>`            | Normal          | Open terminal (Root Dir)               |
| `<F12>`            | Terminal        | Hide terminal                          |

## Plugin Keybindings

### vim-tmux-navigator

Seamless navigation between tmux panes and Neovim splits. These replace the
default `<C-w>h/j/k/l` window navigation.

| Key    | Description                          |
| ------ | ------------------------------------ |
| `C-h`  | Navigate left (pane or Vim split)    |
| `C-j`  | Navigate down (pane or Vim split)    |
| `C-k`  | Navigate up (pane or Vim split)      |
| `C-l`  | Navigate right (pane or Vim split)   |

### Telescope (yadm integration)

| Key             | Description                        |
| --------------- | ---------------------------------- |
| `<leader>fyf`  | Find yadm-tracked files            |
| `<leader>fyp`  | Grep across yadm-tracked files     |

### Flash

The default `s` keymap from flash.nvim is disabled to restore the native `s`
(substitute) behavior.
