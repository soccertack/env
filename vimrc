" <---- start of my vimrc
syn on
map `u :MRU<CR>
map `r :MRU<CR>
map `j vipgq:w<CR>

map `h :exe "let m = matchadd('WildMenu','\\%" . line('.') . "l')"<CR>
map `c :call clearmatches()<CR>

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

function! ResCur()
	if line("'\"") <= line("$")
	normal! g`" 
	return 1
	endif
	endfunction

	augroup resCur
	autocmd!
autocmd BufWinEnter * call ResCur()
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

au FileType gitcommit set tw=72
au FileType c,h,cpp set tw=80
au FileType c,h,cpp set cc=80
au FileType patch set cc=80

set list listchars=tab:▸\ ,trail:•,extends:»,precedes:«

set formatoptions+=croq
set cino+=(0

let MRU_Exclude_Files = '.*COMMIT_EDITMSG'

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
call plug#end()

" end of my vimrc ---->
