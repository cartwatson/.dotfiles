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

" remove background from gitgutter signs
function! s:tweak_gruvbox_gitgutter_colors()
    let g:gitgutter_set_sign_backgrounds=1
    highlight signcolumn      guibg=NONE    ctermbg=NONE
    highlight GitGutterAdd    guifg=#009900 ctermfg=2
    highlight GitGutterChange guifg=#bbbb00 ctermfg=3
    highlight GitGutterDelete guifg=#ff2222 ctermfg=1
endfunction

autocmd! ColorScheme gruvbox call s:tweak_gruvbox_gitgutter_colors()

" set custom color scheme
set background=dark
try
    colorscheme gruvbox
catch
    colorscheme default
endtry

" update refresh time for git-gutter and speed
set updatetime=100 " ms

" column should only be one width
set signcolumn=number


" STATUS LINE =================================================================
" create status line when vim-airline isn't installed

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

" PLUGINS =====================================================================

" toggle gitgutter so I can see line numbers again
nnoremap <C-g> :GitGutterToggle<CR>

" nerdtree shortcuts
nnoremap <C-i> :NERDTreeToggle<CR>
nnoremap <C-f> :NERDTreeFocus<CR>

" show hidden files by default
let g:NERDTreeShowHidden = 1

" group hidden files at top
let g:NERDTreeSortOrder = ['\.$', '\/$', '*' ]

" remove bookmarks and help prompt
let g:NERDTreeMinimalUI = 1

" great example of good variable naming
let g:NERDTreeQuitOnOpen = 3

" Start NERDTree when Vim is started without file arguments.
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists('s:std_in') | NERDTree | endif

" vim command to set nonumber norelativenumber laststatus=0 syntax=off
let s:enabled = 0

function! ZenModeToggle()
    if s:enabled
        set number
        set relativenumber
        set laststatus=2
        set signcolumn=number
        syntax on
        colorscheme gruvbox

        let s:enabled = 0
    else
        set nonumber
        set norelativenumber
        set laststatus=0
        set signcolumn=no
        syntax off
        colorscheme candle-grey

        let s:enabled = 1
    endif
endfunction

command ZenToggle call ZenModeToggle()
nnoremap <C-z> :ZenToggle<CR>

