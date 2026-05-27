" ─── General Settings ─────────────────────────────────────────────────────────
set nocompatible              " Use Vim defaults (not Vi)
set encoding=utf-8            " UTF-8 encoding
set number                    " Show line numbers
set relativenumber            " Relative line numbers
set cursorline                " Highlight current line
set scrolloff=8               " Keep 8 lines above/below cursor
set signcolumn=yes            " Always show sign column
set colorcolumn=100           " Column guide at 100 chars
set nowrap                    " Don't wrap lines
set hidden                    " Allow hidden buffers

" ─── Search ──────────────────────────────────────────────────────────────────
set ignorecase                " Case-insensitive search
set smartcase                 " Unless uppercase is used
set incsearch                 " Incremental search
set hlsearch                  " Highlight search results

" ─── Indentation ─────────────────────────────────────────────────────────────
set tabstop=2                 " Tab = 2 spaces
set shiftwidth=2              " Indent = 2 spaces
set softtabstop=2
set expandtab                 " Use spaces not tabs
set smartindent               " Auto-indent new lines
set autoindent

" ─── Key Mappings ────────────────────────────────────────────────────────────
" jk to exit insert mode (faster than reaching for Esc)
inoremap jk <Esc>

" Clear search highlight with Esc
nnoremap <Esc> :nohlsearch<CR>

" Move between splits with Ctrl+hjkl
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" ─── Appearance ──────────────────────────────────────────────────────────────
syntax on                     " Syntax highlighting
set background=dark           " Dark background
set termguicolors             " True color support
set showmatch                 " Show matching brackets
set laststatus=2              " Always show status line

" ─── Clipboard ───────────────────────────────────────────────────────────────
set clipboard=unnamedplus     " Use system clipboard

" ─── Undo / Backup ───────────────────────────────────────────────────────────
set undofile                  " Persistent undo
set undodir=~/.vim/undodir    " Undo file location
set noswapfile                " No swap files
set nobackup                  " No backup files
