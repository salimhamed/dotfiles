<!-- markdownlint-disable MD013 -->

# 🚀 Alacritty Keymaps

[Back to README](../README.md)

## Custom Keybindings

| Keybinding  | Description                            |
| ----------- | -------------------------------------- |
| `S-Return`  | Send `ESC + Return` (e.g., for Neovim) |

## Default Keybindings

For the full list of Alacritty features and keybindings, see the
[Alacritty features docs](https://github.com/alacritty/alacritty/blob/master/docs/features.md).

### Vi Mode

Enter Vi mode with `C-S-Space`. This enables cursor movement, selection, and
search within the terminal scrollback.

| Keybinding         | Description                            |
| ------------------ | -------------------------------------- |
| `C-S-Space`        | Enter/exit Vi mode                     |
| `h` / `j` / `k` / `l` | Move cursor left/down/up/right    |
| `w` / `b`          | Move forward/backward by word          |
| `0` / `$`          | Move to start/end of line              |
| `^`                | Move to first non-empty cell           |
| `H` / `M` / `L`   | Move to top/middle/bottom of screen    |
| `g` / `G`          | Move to top/bottom of scrollback       |
| `v`                | Start selection                        |
| `V`                | Start line selection                   |
| `C-v`              | Start block selection                  |
| `S-v`              | Start semantic selection               |
| `y`                | Copy selection                         |
| `/` / `?`          | Search forward/backward                |
| `n` / `N`          | Next/previous search match             |

### Search Mode

Enter search mode from Vi mode with `/` (forward) or `?` (backward).

| Keybinding   | Description               |
| ------------ | ------------------------- |
| `Return`     | Confirm search            |
| `Escape`     | Cancel search             |
| `C-u`        | Clear search query        |
| `C-f` / `C-b` | Toggle regex mode       |

### General

| Keybinding        | Description                |
| ----------------- | -------------------------- |
| `C-S-C`           | Copy                       |
| `C-S-V`           | Paste                      |
| `C-S-F`           | Search (reverse)           |
| `C-S-B`           | Search (forward)           |
| `C-+` / `C--`     | Increase/decrease font size |
| `C-0`             | Reset font size            |
