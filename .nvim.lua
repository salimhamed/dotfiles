-- specify GIT_WORK_TREE for yadm so git integration works

vim.env.GIT_DIR = vim.fn.expand("~/.local/share/yadm/repo.git")
vim.env.GIT_WORK_TREE = vim.fn.expand("~")
