# LazyVim Configuration

Personal [LazyVim](https://lazyvim.github.io/) configuration managed with [yadm](https://yadm.io/).

## Quick Reference

| Key | Action |
|-----|--------|
| `<leader>` | Space |
| `<leader>e` | Toggle neo-tree file explorer |
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fp` | Switch project |
| `<leader>cs` | Symbol outline (aerial) |
| `<leader>cr` | Rename (inc-rename live preview) |
| `<leader>ca` | Code actions |
| `<leader>cF` | Format buffer |
| `<leader>tt` | Run nearest test |
| `<leader>tT` | Run all tests in file |
| `<leader>ts` | Toggle test summary |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Continue / start debugging |
| `<leader>du` | Toggle DAP UI |
| `<leader>aa` | Toggle Copilot Chat |
| `<leader>aq` | Quick chat (selected code) |
| `<leader>H` | Add file to harpoon |
| `<leader>h` | Harpoon quick menu |
| `<leader>1`-`<leader>5` | Jump to harpoon file 1-5 |
| `<leader>p` | Browse yank history |
| `]p` / `[p` | Cycle yank ring after paste |
| `<leader>oo` | Overseer task list |
| `<leader>or` | Run task |
| `<F12>` | Toggle terminal |
| `<C-h/j/k/l>` | Navigate tmux/vim panes |
| `<S-Up/Down/Left/Right>` | Resize window |
| `<C-d>` / `<C-u>` | Half-page down/up (centered) |
| `<C-a>` / `<C-x>` | Smart increment/decrement (dial) |
| `Alt+h/j/k/l` | Move line/selection (mini-move) |
| `gC` | Jump to treesitter context |

## Yadm Integration

| Key | Action |
|-----|--------|
| `<leader>fyf` | Find yadm-tracked files |
| `<leader>fyp` | Grep across yadm-tracked files |

## Enabled Extras (31)

### AI
| Extra | Description |
|-------|-------------|
| `ai.copilot` | GitHub Copilot inline suggestions |
| `ai.copilot-chat` | Copilot Chat panel (`<leader>a` prefix) |

### Coding
| Extra | Description |
|-------|-------------|
| `coding.mini-surround` | Add/delete/change surrounding pairs |
| `coding.yanky` | Yank ring with clipboard history and paste cycling |

### DAP (Debugger)
| Extra | Description |
|-------|-------------|
| `dap.core` | Debug Adapter Protocol with breakpoints, stepping, variable inspection |

### Editor
| Extra | Description |
|-------|-------------|
| `editor.aerial` | Symbol outline panel + lualine breadcrumbs |
| `editor.dial` | Smart increment/decrement (booleans, dates, CSS colors) |
| `editor.harpoon2` | Quick file bookmarking and jumping |
| `editor.inc-rename` | Live preview rename across all references |
| `editor.mini-move` | Move lines/selections with `Alt+hjkl` |
| `editor.overseer` | Task runner for build/test/lint commands |
| `editor.telescope` | Telescope as the fuzzy finder |

### Formatting
| Extra | Description |
|-------|-------------|
| `formatting.prettier` | Prettier for web files (JS/TS/CSS/HTML/JSON/YAML/Markdown) |

### Languages
| Extra | Description |
|-------|-------------|
| `lang.ansible` | Ansible language server + ansible-lint |
| `lang.docker` | Dockerfile and docker-compose support |
| `lang.git` | Git commit/rebase message editing |
| `lang.json` | JSON schemas and validation |
| `lang.markdown` | Markdown preview and editing |
| `lang.python` | Pyright + ruff + debugpy + pytest adapter |
| `lang.sql` | SQL LSP for completions and syntax checking |
| `lang.tailwind` | Tailwind CSS class completions and color previews |
| `lang.toml` | TOML schema validation (pyproject.toml, Cargo.toml) |
| `lang.typescript` | vtsls + TypeScript tooling |
| `lang.yaml` | YAML schemas and validation |

### Linting
| Extra | Description |
|-------|-------------|
| `linting.eslint` | ESLint language server with inline diagnostics and auto-fix |

### Test
| Extra | Description |
|-------|-------------|
| `test.core` | Neotest with inline pass/fail indicators and summary panel |

### UI
| Extra | Description |
|-------|-------------|
| `ui.mini-indentscope` | Animated indent scope indicator |
| `ui.treesitter-context` | Pins current function/class at top of window |

### Util
| Extra | Description |
|-------|-------------|
| `util.dot` | Filetype detection for dotfiles |
| `util.mini-hipatterns` | Inline hex color highlighting + Tailwind color previews |
| `util.project` | Project detection and quick switching (`<leader>fp`) |

## Custom Plugins

| Plugin | Purpose |
|--------|---------|
| `stevearc/conform.nvim` | Formatter config: shfmt with 4-space indent + case indent |
| `folke/flash.nvim` | Disabled default `s` keymap to free it for other uses |
| `nvim-neo-tree/neo-tree.nvim` | File explorer with nvim-window-picker (floating big letter hints) |
| `rcarriga/nvim-notify` | Minimal, static notifications (level 3 = WARN+) |
| `nvim-telescope/telescope.nvim` | Yadm file finder and grep keymaps |
| `christoomey/vim-tmux-navigator` | Seamless `<C-h/j/k/l>` navigation between tmux panes and vim splits |
| `folke/which-key.nvim` | Custom yadm group under `<leader>fy` |

## Formatter Assignments

| Filetype | Formatter |
|----------|-----------|
| JavaScript / TypeScript / JSX / TSX | prettierd |
| CSS / HTML | prettierd |
| JSON / YAML / Markdown | prettierd |
| Shell (sh / bash / zsh) | shfmt (4-space indent, case indent) |
| Lua | stylua |
| Python | ruff |

## LSP Servers

| Language | Server |
|----------|--------|
| Python | pyright + ruff |
| TypeScript / JavaScript | vtsls + eslint |
| Tailwind CSS | tailwindcss |
| Ansible | ansible-language-server |
| SQL | sqlls |
| Docker | dockerls + docker_compose_language_service |
| JSON | jsonls |
| YAML | yamlls |
| TOML | taplo |
| Markdown | marksman |
| Lua | lua_ls |

## Configuration Notes

- **Picker:** Telescope (set in `options.lua` via `vim.g.lazyvim_picker`)
- **Python LSP:** Pyright (not basedpyright), with ruff for linting/formatting
- **Terminal toggle:** Remapped from `<C-/>` to `<F12>` (Snacks terminal)
- **Window resize:** Remapped from `<C-Arrow>` to `<S-Arrow>` (frees Ctrl+Arrow for tmux)
- **Cursor centering:** `<C-d>`, `<C-u>`, `n`, `N` all keep cursor centered
- **Local config:** `exrc` enabled — project-local `.nvim.lua` files are sourced
