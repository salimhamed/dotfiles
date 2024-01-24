"configure clipboard
set clipboard+=unnamedplus

"rebind <Leader> key
let mapleader = " "

"mouse and backspace
set mouse=a  "on OSX press ALT and click
set bs=2 "make backspace behave like normal again

"bind nohl to remove highlight of your last search
noremap <C-n> :nohl<CR>
vnoremap <C-n> :nohl<CR>
inoremap <C-n> :nohl<CR>

"bind Ctrl+<movement> keys to move around the windows
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l
map <c-h> <c-w>h

"easier moving of code blocks
vnoremap < <gv
vnoremap > >gv

"map sort function to a key
vnoremap <Leader>s :sort<CR>

"global tab settings
"file specific settings can be changed in the ftplugin directory
set expandtab "tabs are spaces
set shiftround "round to nearest tab width when moving blocks of text
set smartindent "automatically indent when starting a new line
set tabstop=4 "number of visual spaces per tab
set shiftwidth=4 "number of spaces to use for each step of (auto)indent
set softtabstop=4 "number of spaces in tab when editing

"ui config
set number "show line numbers
set ruler "show the line and column number of the cursor position
set showcmd "show command in bottom bar
set colorcolumn=80 "show column at 80 characters
set wildmenu "visual autocomplete for command menu
set showmatch "highlight matching brackets and parentheses
set title

"status bar settings
set laststatus=2 "Always display the statusline in all windows
set showtabline=2 "Always display the tabline, even if there is only one tab
set noshowmode "Hide the default mode text (e.g. -- INSERT -- below the statusline)

"allow hidden buffers for switching between buffers without saving
set hidden

"turn of word wrapping
set nowrap

"disable swap files
set noswapfile

"searching"
set hlsearch "highlight matches
set incsearch "search as characters are entered
set ignorecase "ignore case on search
set smartcase "override the ignore case setting when searching with uppercase

" workaround for not unfolding code when moving cursor
" https://github.com/vscode-neovim/vscode-neovim/issues/58#issuecomment-630551787
nmap j gj
nmap k gk
