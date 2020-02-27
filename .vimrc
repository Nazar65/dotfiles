"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                               "
" Version: 0.1                                                  "
"                                                               "
"                                                               "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Plugins and indentation based on the file type
filetype plugin indent on
filetype off " required

"=====================================================
" Vundle settings
"=====================================================
"
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" load plugins
if filereadable(expand("~/.vimrc.plugins"))
  source ~/.vimrc.plugins
endif

call vundle#end()            		    " required
filetype on
filetype plugin on
filetype plugin indent on

"=====================================================
" General settings
"=====================================================
let g:auto_save = 1                     "Enable autosave on startup
let g:auto_save_silent = 1              " do not display the auto-save notification

"=====================================================
" Autocompletion php settings
" ====================================================
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
let g:phpcomplete_parse_docblock_comments =1

"=====================================================
" Autocompletion php settings end
" ====================================================
"
inoremap <C-G> <ESC>:call PhpDocSingle()<CR>i
nnoremap <C-G> :call PhpDocSingle()<CR>
vnoremap <C-G> :call PhpDocRange()<CR> 
" performance settings
set timeoutlen=1000
set ttimeoutlen=0
" end

command! -nargs=* SetPhpUnitConfig call phpTests#togglePhpUnitConfig(<f-args>)

set backspace=indent,eol,start
aunmenu Help.
aunmenu Window.
set t_Co=256
set ruler
set completeopt-=preview
set gcr=a:blinkon0
let no_buffers_menu=1
syntax on                                  "Hightlight the ifs and buts
colorscheme gruvbox-material
set background=dark
set mousemodel=popup
set smarttab
set tabstop=4 shiftwidth=4 expandtab       "Code style to not use tabs
set autoread                               "auto refreshing changed  files 
au CursorHold * checktime
set enc=utf-8	     
set ls=2             
set incsearch	     
set hlsearch	     
set nu	             
set scrolloff=5	     
tab sball
set switchbuf=useopen
set nobackup 	                          " no backup files
set nowritebackup                         " only in case you don't want a backup file while editing
set noswapfile 	     
map <Leader>y "+y                         " Copy to system buffer
map <Leader>p "+gp
map <C-x> :bd<CR>                         " Close current buffer
map <C-a> :Bufonly<CR>                    " Close all active bufers levae active

" copy paste settings from one vim instance to other
if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
endif

" phpUnitConfig
let g:phpUnitBinFile = '/Projects/magento24dev/vendor/bin/phpunit'
let g:phpTestUnitDist = '/Projects/magento24dev/dev/tests/static/phpunit.xml.dist'

augroup vimrc_autocmds
    autocmd!
    autocmd FileType php,ruby,python,javascript,c,cpp highlight Excess ctermbg=DarkGrey guibg=Black
    autocmd FileType php,ruby,python,javascript,c,cpp match Excess /\%120v.*/
    autocmd FileType php,ruby,python,javascript,c,cpp set nowrap
augroup END

let g:snippets_dir = "~/.vim/vim-snippets/snippets"
set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#hunks#enabled=1

map <F4> :TagbarToggle<CR>
let g:tagbar_autofocus = 0 

nnoremap <F3>  :call ToggleNetrw()<CR>

let g:netrw_banner = 0
let g:netrw_altv = 1
let g:netrw_liststyle=3
let g:netrw_sort_by= "name"
let g:netrw_winsize = 10

" FILE BROWSER STARTUP
let g:NetrwIsOpen=0
function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i 
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction
nnoremap <silent> <Leader>+ :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 2/3)<CR>

"====================================================
" FZF & Ag settings
"====================================================
"
" Show preview window with Ag search
command! -bang -nargs=* Ag call fzf#vim#ag('',<bang>0 ? fzf#vim#with_preview('up:60%') : fzf#vim#with_preview('right:60%', '?'), <bang>0)

"====================================================
" Python-mode settings
"====================================================

let g:pymode_rope = 0
let g:pymode_rope_completion = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_doc = 0
let g:pymode_doc_key = 'K'
let g:pymode_lint = 1
let g:pymode_lint_checker = "pyflakes,pep8"
let g:pymode_lint_ignore="E501,W601,C0110"
let g:pymode_lint_write = 1
let g:pymode_virtualenv = 1
let g:pymode_breakpoint = 1
let g:pymode_breakpoint_key = '<leader>b'
let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all
let g:pymode_folding = 0
let g:pymode_run = 0 
