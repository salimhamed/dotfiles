<!-- markdownlint-disable MD013 -->

# 🚀 Neovim Keymaps

> ⬅️ [Back to README](../README.md)

Configured using [LazyVim](https://github.com/LazyVim/LazyVim) as the base
distribution. See the
[LazyVim keymaps reference](https://www.lazyvim.org/keymaps) for all default
keybindings. The `<Leader>` key is `Space`.

## Custom Keybindings

| Key                | Mode            | Description                                         |
| ------------------ | --------------- | --------------------------------------------------- |
| `<leader>yp`      | Normal          | Yank relative path to clipboard                     |
| `<leader>yP`      | Normal          | Yank absolute path to clipboard                     |
| `<leader>yr`      | Normal          | Yank file reference with line number (path:line)    |
| `<leader>yr`      | Visual          | Yank file reference with line range (path:line-line) |
| `<C-d>`           | Normal          | Half-page scroll down + center cursor               |
| `<C-u>`           | Normal          | Half-page scroll up + center cursor                 |
| `n`               | Normal          | Search next + center + open folds                   |
| `N`               | Normal          | Search prev + center + open folds                   |

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
