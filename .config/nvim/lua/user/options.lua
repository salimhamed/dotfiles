-- file encoding
vim.opt.fileencoding = "utf-8"

-- turn on relative line numbers
vim.opt.relativenumber = true

-- enable filetype detection
vim.cmd("filetype on")

-- use system clipboard
vim.opt.clipboard = "unnamedplus"

-- mouse and backspace
vim.opt.mouse = "a"
vim.opt.bs = "2"

-- window splitting
vim.opt.splitbelow = true
vim.opt.splitright = true

-- smart auto-indentation
vim.opt.shiftround = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.shiftwidth = 2

-- show line numbers
vim.opt.number = true

-- hide line and column numbers in the status bar
vim.opt.ruler = false

-- do not show partial commands
vim.opt.showcmd = true

-- show column line
vim.opt.colorcolumn = "100"

-- show matching brackets
vim.opt.showmatch = true

-- status bar settings
vim.opt.laststatus = 2
vim.opt.showtabline = 2
vim.opt.showmode = false

-- allow hidden buffers for switching between buffers without saving
vim.opt.hidden = true

-- turn off word wrapping
vim.opt.wrap = false

-- disable swap files and backups
vim.opt.swapfile = false
vim.opt.backup = false

-- searching
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- allow sourcing of .exrc, .nvimrc and .nvim.lua
vim.opt.exrc = true
vim.opt.secure = true

-- height of the vim command line
vim.opt.cmdheight = 1

-- turn on gui colors
vim.opt.termguicolors = true

-- highlight current line
vim.opt.cursorline = false

-- do not automattically add newlines to the end of files
vim.opt.fixendofline = false

-- enable
vim.lsp.enable("bashls")
