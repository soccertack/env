" <---- start of my vimrc
syn on
map `u :MRU<CR>
"Make a paragraph align to the line width and save it
map `j mmvipgq`m:w<CR>
map `k f=w*<C-]>

"Switch to the previous buffer
map `i :b#<CR>

map `h :exe "let m = matchadd('WildMenu','\\%" . line('.') . "l')"<CR>
map `c :call clearmatches()<CR>

"Always hide line numbers
map `n :set nu! nornu \| :GitGutterToggle<CR>
"Toggle relative/absolute line numbers
map `r :set nu rnu!<CR>

set autoindent
set smartindent

set incsearch
set hls 
hi Search ctermfg=Black ctermbg=6
hi Comment ctermfg=6
hi MatchParen cterm=bold ctermbg=none ctermfg=magenta

set ignorecase
set smartcase

set nu
set laststatus=2
set statusline=%t%h%m%r%=%l/%L\ %P\ \ 

"https://vim.fandom.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
function! ResCur()
    if line("'\"") <= line("$")
        normal! g`"
        return 1
    endif
endfunction

augroup resCur
    autocmd!
    autocmd BufWinEnter * if index(['gitcommit'], &ft) < 0 | call ResCur()
augroup END

"http://vi.stackexchange.com/questions/2545/how-can-i-run-an-autocmd-when-starting-vim-with-no-file-a-non-existing-file-or
function InsertIfEmpty()
    if @% == ""
        " No filename for current buffer
        MRU 
    endif
endfunction

au VimEnter * call InsertIfEmpty()

"highlight OverLength ctermbg=red ctermfg=white guibg=#592929
"match OverLength /\%81v.\+/

highlight ColorColumn ctermbg=19

" Set tex file to letex always, not plaintex
let g:tex_flavor = "latex"

au FileType gitcommit set tw=72
au FileType tex set tw=70
au FileType c,h,cpp set tw=80
au FileType c,h,cpp set cc=80
au FileType patch set cc=80

set list listchars=tab:▸\ ,trail:•,extends:»,precedes:«

set formatoptions+=croq
set cino+=(0

let MRU_Exclude_Files = '.*COMMIT_EDITMSG\|.*fugitiveblame*'

"Quickfix related setting
autocmd QuickFixCmdPost *grep* cwindow
map <C-j> :cn<CR>
map <C-k> :cp<CR>

"Install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"Install plugins
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/google/vim-searchindex.git'
Plug 'https://github.com/soccertack/mru.git'
Plug 'https://github.com/tpope/vim-fugitive.git'
Plug 'https://github.com/soccertack/cscope.git'
Plug 'https://github.com/vim-scripts/taglist.vim.git'
Plug 'airblade/vim-gitgutter'
Plug 'lifepillar/vim-solarized8'
call plug#end()

"Make taglist more responsive.
set ut=100

map <C-t> :TlistToggle<CR>

set tabstop=8
set shiftwidth=8
set softtabstop=0
set noexpandtab

"set tabstop=4       " The width of a TAB is set to 4.
"                    " Still it is a \t. It is just that
"                    " Vim will interpret it to be having
"                    " a width of 4.
"set shiftwidth=4    " Indents will have a width of 4.
"set softtabstop=4   " Sets the number of columns for a TAB.
"set expandtab       " Expand TABs to spaces.

" This enables to jump between matching keywords like #ifdef
"set nocompatible
"filetype plugin on
"runtime macros/matchit.vim

"Ignore files having certain extensions
set wildignore+=*.aux

nnoremap * *<c-o>
nnoremap a A
nnoremap A a

"Don't set indent for tex files
au FileType tex setlocal indentexpr=

"This is to get the quickfix window for cscope results
set cscopequickfix=

"Don't move line up or down with right/left keys
set ww-=h,l

autocmd FileType gitcommit setlocal indentexpr=''

set background=dark
colorscheme solarized8

"Go back and forth between new changes
nnoremap <silent> <cr> :GitGutterNextHunk<cr>
nnoremap <silent> <backspace> :GitGutterPrevHunk<cr>
" end of my vimrc ---->
