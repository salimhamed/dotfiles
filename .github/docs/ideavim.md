<!-- markdownlint-disable MD013 -->

# 🔧 IdeaVim Keymaps

[Back to README](../README.md)

The `<Leader>` key is `Space`.

## Navigation

| Key           | Description                            |
| ------------- | -------------------------------------- |
| `<leader>j`   | EasyMotion forward search              |
| `<leader>J`   | EasyMotion backward search             |
| `C-h/j/k/l`   | Navigate between splits                |
| `S-l` / `S-h` | Next / previous tab                    |
| `C-d` / `C-u` | Half-page scroll + center              |
| `n` / `N`     | Search next/prev + center + open folds |
| `C-n`         | Clear search highlight                 |

## Window Management

| Key                    | Description                |
| ---------------------- | -------------------------- |
| `S-Up/Down/Left/Right` | Stretch split in direction |
| `C-w q`                | Close all editors          |

## File Explorer and Find

| Key          | Description                           |
| ------------ | ------------------------------------- |
| `<leader>e`  | Toggle NERDTree (project tool window) |
| `<leader>fe` | Search Everywhere                     |
| `<leader>fr` | Recent Files                          |
| `<leader>fc` | Find Class                            |
| `<leader>fa` | Search Actions                        |
| `<leader>ff` | Find File                             |
| `<leader>fs` | Find Symbol                           |
| `<leader>fp` | Search Within Files (Find in Path)    |

## Buffer Management

| Key              | Description                  |
| ---------------- | ---------------------------- |
| `<leader>bd`     | Delete buffer                |
| `<leader>br`     | Close buffers to the right   |
| `<leader>bl`     | Close buffers to the left    |
| `<leader>ba`     | Close all but current buffer |
| `<leader>bm`     | Move to opposite tab group   |
| `<leader>b<C-v>` | Split and move right         |
| `<leader>b<C-->` | Split and move down          |

## LSP

| Key  | Description                   |
| ---- | ----------------------------- |
| `gr` | Goto references (Find Usages) |
| `go` | Goto type definition          |
| `gq` | Quick implementations         |
| `gb` | Goto database view            |

## Other

| Key                | Description                         |
| ------------------ | ----------------------------------- |
| `C-\`              | Toggle terminal tool window         |
| `C-S`              | Save current buffer                 |
| `p` (visual)       | Paste without yanking replaced text |
| `<` / `>` (visual) | Indent block and reselect           |
