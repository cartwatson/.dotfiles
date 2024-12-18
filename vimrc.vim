" credit to 
" - https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/
" - https://jeffkreeftmeijer.com/vim-number/
" - https://www.shortcutfoo.com/blog/top-50-vim-configuration-options

" GENERAL ===================================================================== 

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

syntax on
set number relativenumber

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Load an indent file for the detected file type.
" filetype indent on

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" tabs/indentation
set expandtab " convert tab to spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4

set autoindent
set smarttab

" search
set hlsearch
set ignorecase
set smartcase

" don't wrap in the middle of a word
set linebreak 

" STATUS LINE =================================================================

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
" set statusline+=\ %F\ %M\ %Y\ %R
set statusline+=%f\ %M\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ %y\ ln:\ %l/%L,\ %c

" Show the status on the second to last line.
set laststatus=2


" CUSTOM CONFIG ===============================================================

" always show tabline 0=never, 1=default, 2=always
set showtabline=2

" auto indent based on previous line
set smartindent

" only care about case if I use various cases
set smartcase

" ignore case for file completion
set wildignorecase

" set split direction
set splitbelow
set splitright

" alias for vertical terminal
command T vertical terminal

" alias for when you accidentally hold shift
command W write

