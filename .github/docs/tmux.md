<!-- markdownlint-disable MD013 -->

# 💻 Tmux Keymaps

[Back to README](../README.md)

## Prefix

The prefix is remapped to `C-a` (default `C-b`). When connecting over
[mosh](https://mosh.org/), the prefix is automatically switched back to `C-b`
for compatibility with mobile clients (via `refresh-status.sh`).

## Custom Keybindings

| Keybinding       | Description                                          |
| ---------------- | ---------------------------------------------------- |
| `<Prefix> r`     | Reload tmux config                                   |
| `<Prefix> C-]`   | Next window                                          |
| `<Prefix> C-[`   | Previous window                                      |
| `<Prefix> h/j/k/l` | Select pane (vi-style)                            |
| `<Prefix> C-v`   | Vertical split (current path)                        |
| `<Prefix> C-_`   | Horizontal split (current path)                      |
| `<Prefix> S-Up`  | Resize pane 5 rows up                                |
| `<Prefix> S-Down` | Resize pane 5 rows down                             |
| `<Prefix> S-Right` | Resize pane 5 columns right                        |
| `<Prefix> S-Left` | Resize pane 5 columns left                          |
| `<Prefix> C-l`   | Clear screen (since `C-l` is used by vim-tmux-navigator) |
| `v` (copy mode)  | Begin selection (vi-style)                           |
| `F12`            | Toggle outer session off/on for nested tmux sessions |

## Plugin Keybindings

### vim-tmux-navigator

Seamless navigation between tmux panes and Vim splits. These bindings work
without a prefix.

| Keybinding | Description                          |
| ---------- | ------------------------------------ |
| `C-h`      | Navigate left (pane or Vim split)    |
| `C-j`      | Navigate down (pane or Vim split)    |
| `C-k`      | Navigate up (pane or Vim split)      |
| `C-l`      | Navigate right (pane or Vim split)   |

### tmux-yank

| Keybinding       | Description                                 |
| ---------------- | ------------------------------------------- |
| `y` (copy mode)  | Yank selection to system clipboard (stays in copy mode) |

### tmux-resurrect

| Keybinding       | Description      |
| ---------------- | ---------------- |
| `<Prefix> C-s`   | Save session     |
| `<Prefix> C-r`   | Restore session  |

### tmux-fuzzback

| Keybinding     | Description                              |
| -------------- | ---------------------------------------- |
| `<Prefix> ?`   | Fuzzy search scrollback buffer via fzf   |

### extrakto

| Keybinding      | Description                                      |
| --------------- | ------------------------------------------------ |
| `<Prefix> Tab`  | Extract and select tokens (URLs, paths) from scrollback |

### tmux-sessionx

| Keybinding     | Description                                   |
| -------------- | --------------------------------------------- |
| `<Prefix> o`   | Fuzzy session picker with zoxide integration  |

## Default Tmux Keybindings

Curated list of common built-in tmux keybindings for reference.

### Copy Mode

| Keybinding       | Description                        |
| ---------------- | ---------------------------------- |
| `<Prefix> [`     | Enter copy mode                    |
| `q`              | Exit copy mode                     |
| `Space`          | Begin selection (default)          |
| `Enter`          | Copy selection and exit            |
| `/` / `?`        | Search forward/backward            |
| `n` / `N`        | Next/previous search match         |

### Windows

| Keybinding       | Description                                |
| ---------------- | ------------------------------------------ |
| `<Prefix> c`     | Create new window                          |
| `<Prefix> &`     | Kill current window                        |
| `<Prefix> 0-9`   | Go to window by index                      |
| `<Prefix> f`     | Find window                                |
| `<Prefix> w`     | List all windows                           |
| `<Prefix> ,`     | Rename current window                      |

### Panes

| Keybinding       | Description                     |
| ---------------- | ------------------------------- |
| `<Prefix> z`     | Toggle zoom on current pane     |
| `<Prefix> x`     | Kill current pane               |
| `<Prefix> >`     | Pane action menu                |
| `<Prefix> <`     | Window action menu              |

### Sessions

| Keybinding              | Description                          |
| ----------------------- | ------------------------------------ |
| `<Prefix> s`            | List and select sessions             |
| `<Prefix> (`            | Previous session                     |
| `<Prefix> )`            | Next session                         |
| `<Prefix> :new -s name` | Create a new named session          |

### Plugin Management (TPM)

| Keybinding       | Description        |
| ---------------- | ------------------ |
| `<Prefix> I`     | Install plugins    |
| `<Prefix> u`     | Update plugins     |
| `<Prefix> M-u`   | Uninstall plugins  |

## Command Prompt Mode

Use `<Prefix> :` to enter command prompt mode. Common commands:

| Command            | Description                                        |
| ------------------ | -------------------------------------------------- |
| `list-commands`    | List all available commands                        |
| `kill-server`      | Kill the tmux server                               |
| `list-keys`        | Show all keybindings for the current session       |
| `respawn-pane -k`  | Restart a pane with its initial command             |
| `swap-window -t 2` | Swap the current window with the window at index 2 |
