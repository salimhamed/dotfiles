-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = LazyVim.safe_keymap_set
local _git_base_ref = nil
local _git_status_patched = false

-- neo-tree's git.status() caches raw `git status` output per worktree. On a
-- cache hit it returns early WITHOUT the base-diff third return value, even
-- though the diff was computed and stored on the first call. This patch falls
-- back to the stored status_diff when the cache-hit path drops it.
local function _ensure_git_status_patch()
  if _git_status_patched then
    return
  end
  _git_status_patched = true
  local egsp_git = require("neo-tree.git")
  local egsp_original = egsp_git.status
  egsp_git.status = function(egsp_path, egsp_base_lookup, egsp_skip_bubbling, egsp_opts)
    local egsp_status, egsp_root, egsp_over_base =
      egsp_original(egsp_path, egsp_base_lookup, egsp_skip_bubbling, egsp_opts)
    if egsp_status and egsp_root and not egsp_over_base and egsp_base_lookup then
      local egsp_base = egsp_base_lookup[egsp_root]
      local egsp_wt = egsp_base and egsp_git.worktrees[egsp_root]
      if egsp_wt and egsp_wt.status_diff then
        egsp_over_base = egsp_wt.status_diff[egsp_base]
      end
    end
    return egsp_status, egsp_root, egsp_over_base
  end
end

-- Yank relative path to clipboard (e.g., src/file.lua)
map("n", "<leader>yp", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Yank Relative File Path" })

-- Yank absolute path to clipboard (e.g., /Users/.../src/file.lua)
map("n", "<leader>yP", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Yank Absolute File Path" })

-- Yank file reference with current line number (e.g., src/file.lua:42)
map("n", "<leader>yr", function()
  local ref = vim.fn.expand("%:.") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Yank Reference" })

-- Yank file reference with line range from visual selection (e.g., src/file.lua:10-15)
map("v", "<leader>yr", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  local l1 = math.min(start_line, end_line)
  local l2 = math.max(start_line, end_line)
  local path = vim.fn.expand("%:.")
  local ref = l1 == l2 and (path .. ":" .. l1) or (path .. ":" .. l1 .. "-" .. l2)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Yank Reference" })

-- Yank absolute file reference with current line number (e.g., /Users/.../file.lua:42)
map("n", "<leader>yR", function()
  local ref = vim.fn.expand("%:p") .. ":" .. vim.fn.line(".")
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
end, { desc = "Yank Absolute Reference" })

-- Yank absolute file reference with line range from visual selection (e.g., /Users/.../file.lua:10-15)
map("v", "<leader>yR", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  local l1 = math.min(start_line, end_line)
  local l2 = math.max(start_line, end_line)
  local path = vim.fn.expand("%:p")
  local ref = l1 == l2 and (path .. ":" .. l1) or (path .. ":" .. l1 .. "-" .. l2)
  vim.fn.setreg("+", ref)
  vim.notify("Copied: " .. ref)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end, { desc = "Yank Absolute Reference" })

-- Change git base for gitsigns and neo-tree together
vim.api.nvim_create_user_command("GitBase", function(ghc_opts)
  _ensure_git_status_patch()
  local ghc_ref = vim.trim(ghc_opts.args)
  local ghc_manager = require("neo-tree.sources.manager")
  local ghc_git = require("neo-tree.git")
  local ghc_renderer = require("neo-tree.ui.renderer")
  local ghc_fs_state = ghc_manager.get_state("filesystem")
  local ghc_gs_state = ghc_manager.get_state("git_status")
  local ghc_path = ghc_fs_state.path or vim.fn.getcwd()
  local ghc_worktree_root = ghc_git.find_worktree_info(ghc_path)
  if ghc_ref == "" then
    _git_base_ref = nil
    require("gitsigns").reset_base(true)
    if ghc_worktree_root then
      if ghc_fs_state.git_base_by_worktree then
        ghc_fs_state.git_base_by_worktree[ghc_worktree_root] = nil
      end
      if ghc_gs_state.git_base_by_worktree then
        ghc_gs_state.git_base_by_worktree[ghc_worktree_root] = nil
      end
    end
    if ghc_renderer.window_exists(ghc_fs_state) then
      ghc_manager.navigate(ghc_fs_state, ghc_fs_state.path)
    end
    if ghc_renderer.window_exists(ghc_gs_state) then
      ghc_manager.navigate(ghc_gs_state, ghc_gs_state.path)
    end
    vim.notify("Git base reset to default")
  else
    _git_base_ref = ghc_ref
    require("gitsigns").change_base(ghc_ref, true)
    if ghc_worktree_root then
      ghc_fs_state.git_base_by_worktree = ghc_fs_state.git_base_by_worktree or {}
      ghc_fs_state.git_base_by_worktree[ghc_worktree_root] = ghc_ref
      ghc_gs_state.git_base_by_worktree = ghc_gs_state.git_base_by_worktree or {}
      ghc_gs_state.git_base_by_worktree[ghc_worktree_root] = ghc_ref
    end
    if ghc_renderer.window_exists(ghc_fs_state) then
      ghc_manager.navigate(ghc_fs_state, ghc_fs_state.path)
    end
    if ghc_renderer.window_exists(ghc_gs_state) then
      ghc_manager.navigate(ghc_gs_state, ghc_gs_state.path)
    end
    vim.notify("Git base set to " .. ghc_ref)
  end
end, {
  nargs = "?",
  complete = function(ghc_lead)
    local ghc_branches = vim.fn.systemlist({ "git", "branch", "-a", "--format=%(refname:short)" })
    return vim.tbl_filter(function(ghc_b)
      return ghc_b:find(ghc_lead, 1, true) == 1
    end, ghc_branches)
  end,
  desc = "Set git base for gitsigns and neo-tree",
})
map("n", "<leader>ghc", ":GitBase ", { desc = "Change Git Base", silent = false })

map("n", "<leader>ge", function()
  _ensure_git_status_patch()
  local ge_args = { source = "git_status", toggle = true }
  if _git_base_ref then
    ge_args.git_base = _git_base_ref
    require("neo-tree.sources.manager").get_state("git_status").dirty = true
  end
  require("neo-tree.command").execute(ge_args)
end, { desc = "Git Explorer" })

-- Restart all LSP clients for the current buffer
map("n", "<leader>cx", "<cmd>LspRestart<cr>", { desc = "󰜉 Restart LSP" })

-- Keep cursor centered when moving 1/2 pages
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- Keep cursor centered when moving through search results and open folds
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Split and send current buffer to new window, show alternate in original
-- If no alternate buffer exists, just perform a normal split
map("n", "<leader>wV", function()
  local alt_buf = vim.fn.bufnr("#")
  vim.cmd("vsplit")
  if alt_buf ~= -1 and vim.api.nvim_buf_is_valid(alt_buf) then
    vim.cmd("wincmd p")
    vim.cmd("buffer " .. alt_buf)
    vim.cmd("wincmd p")
  end
end, { desc = "Split window vertically & send" })

-- Same as above but with a horizontal split
map("n", "<leader>wS", function()
  local alt_buf = vim.fn.bufnr("#")
  vim.cmd("split")
  if alt_buf ~= -1 and vim.api.nvim_buf_is_valid(alt_buf) then
    vim.cmd("wincmd p")
    vim.cmd("buffer " .. alt_buf)
    vim.cmd("wincmd p")
  end
end, { desc = "Split window & send" })
