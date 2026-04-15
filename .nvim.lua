-- Set yadm GIT_DIR only when launching nvim at exactly $HOME.
-- Without this guard, nvim's 'exrc' walks up parent dirs and sources this
-- file from every project under ~, leaking yadm's repo into unrelated projects.

if vim.fn.getcwd() == vim.env.HOME then
  vim.env.GIT_DIR = vim.fn.expand("~/.local/share/yadm/repo.git")
  vim.env.GIT_WORK_TREE = vim.fn.expand("~")
end
