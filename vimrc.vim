" credit to 
" - https://www.freecodecamp.org/news/vimrc-configuration-guide-customize-your-vim-editor/
" - https://jeffkreeftmeijer.com/vim-number/

" GENERAL ------------------------------------------------------------ {{{

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

syntax on
set number relativenumber

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Load an indent file for the detected file type.
filetype indent on

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" }}}


" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ row:\ %l\ col:\ %c

" Show the status on the second to last line.
set laststatus=2

" }}}