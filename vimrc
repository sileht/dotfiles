set nocompatible

call plug#begin('~/.vim/plugged')
" Style
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/syntastic'
Plug 'bling/vim-bufferline'
Plug 'mhinz/vim-signify'                " VCS diff
" Homepage
Plug 'mhinz/vim-startify'
" Text navigation
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
" File/Tag browsing
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tacahiroy/ctrlp-funky'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
" Language
Plug 'tpope/vim-fugitive'                        " Git
Plug 'klen/python-mode', { 'branch': 'develop' } " Python
Plug 'davidhalter/jedi-vim'                      " Python
Plug 'spf13/PIV'                                 " PHP
Plug 'Rykka/riv.vim'                             " Rst
Plug 'rodjek/vim-puppet'                         " Puppet
Plug 'pangloss/vim-javascript'                   " Js
Plug 'groenewege/vim-less'                       " Less
Plug 'elzr/vim-json'                             " Json 
Plug 'tpope/vim-rails'                           " Ruby
Plug 'fatih/vim-go'                              " Go
Plug 'tpope/vim-markdown'                        " Markdown
"Plug 'saltstack/salt-vim'                        " Salt
Plug 'amirh/HTML-AutoCloseTag'                   " HTML autoclose
Plug 'hail2u/vim-css3-syntax'                    " Css

call plug#end()

scriptencoding utf-8
syntax on
filetype plugin indent on

set clipboard=unnamed,unnamedplus
set hidden                  " Allow buffer switching without saving
set backup                  " Backups are nice ...
set undofile                " So is persistent undo ...
set undolevels=1000         " Maximum number of changes that can be undone
set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
"set number                      " Line numbers on
set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
"set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
"set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
set scrolljump=5                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
"set list
"set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
set textwidth=79
set colorcolumn=80
set nowrap                      " Do not wrap long lines
set autoindent                  " Indent at the same level of the previous line
set shiftwidth=4                " Use indents of 4 spaces
set expandtab                   " Tabs are spaces, not tabs
set tabstop=4                   " An indentation every four columns
set softtabstop=4               " Let backspace delete indent
set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
set splitright                  " Puts new vsplit windows to the right of the current
set splitbelow                  " Puts new split windows to the bottom of the current
"set matchpairs+=<:>             " Match, to be used with %
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
set nofoldenable                " No fold
set scrolloff=10                " Again no fold

let mapleader = ","
let g:mapleader = ","

" Paste last yank
nnoremap P "0p
" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$
" Clean hlsearch on new search
nmap <silent> <leader>/ :nohlsearch<CR>

map <C-n> :NERDTreeToggle<CR>
map <leader>e :NERDTreeFind<CR>
nmap <leader>nt :NERDTreeFind<CR>

imap <silent> <Esc>OA <Up>
imap <silent> <Esc>OB <Down>
imap <silent> <Esc>OC <Right>
imap <silent> <Esc>OD <Left>
imap <silent> <Esc>OH <Home>
imap <silent> <Esc>OF <End>
imap <silent> <Esc>[5~ <PageUp>
imap <silent> <Esc>[6~ <PageDown>]]

map <F6> :w<CR>:!aspell -l en -c %<CR>:e %<CR>
map <F7> :w<CR>:!aspell -l fr -c %<CR>:e %<CR>
nmap <silent> <F8> :call ToggleSpell()<CR>
"nmap <C-e> :TagbarToggle<CR>

nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <leader>- <Plug>AirlineSelectPrevTab
nmap <leader>+ <Plug>AirlineSelectNextTab
nmap <S-left>  <Plug>AirlineSelectPrevTab
nmap <S-right> <Plug>AirlineSelectNextTab

nnoremap <C-e> :CtrlPFunky<Cr>
" narrow the list down with a word under cursor
nnoremap <C-E> :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

"""""""""""
" On load "
"""""""""""

" Change cwd to file directory
autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

" No ending space
autocmd BufNewFile,BufRead *.yaml set filetype=yml
autocmd BufNewFile,BufRead *.pyx set filetype=python
autocmd BufWritePre *.yaml,*.pyx,*.rst call StripTrailingWhitespace()
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> call StripTrailingWhitespace()

autocmd BufWritePre,BufRead *.js :set tabstop=2 shiftwidth=2

" Restore cursor position
function! ResCur()
    if line("'\"") <= line("$")
	silent! normal! g`"
	return 1
    endif
endfunction
augroup resCur
    autocmd!
    autocmd BufWinEnter * call ResCur()
augroup END


""""""""""
" Themes "
""""""""""
set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
set background=dark
let g:gruvbox_italic=1
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox

set cursorline
set laststatus=2        " Show statusbar

"""""""""""""""
" Plug config "
"""""""""""""""
let g:airline_powerline_fonts = 1 
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1

let g:signify_update_on_focusgained = 1

"let g:syntastic_html_tidy_exec = 'tidy5'
let g:syntastic_python_checkers = ['flake8']
"let g:syntastic_quiet_messages = { "regex":['\m\[invalid-name\]', '\m\[missing-docstring\]' ]}
"let g:syntastic_quiet_messages = { "type": "style" }
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:virtualenv_directory = '.tox/'
let g:virtualenv_auto_activate = 1

let NERDTreeShowBookmarks=1
let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1
let g:nerdtree_tabs_open_on_gui_startup=0

let g:rubycomplete_buffer_loading = 1
"let g:rubycomplete_classes_in_global = 1
"let g:rubycomplete_rails = 1

let g:pymode_lint = 1
let g:pymode_lint_unmodified = 1
let g:pymode_lint_checkers = ['pyflakes' ,'pep8']
let g:pymode_lint_sort = ['E','W', 'C','I']
let g:pymode_folding = 0
let g:pymode_options = 0
let g:pymode_lint_ignore = 'E265,W0621,E731'
let g:pymode_trim_whitespaces = 0        " We already do this manually
let g:pymode_options = 0                 " No options
let g:pymode_rope = 0                    " No rope project
let g:pymode_rope_lookup_project = 0     " I said no rope
let g:pymode_rope_completion = 0         " Again
let g:pymode_rope_complete_on_dot = 0    " And again

let g:ctrlp_funky_matchtype = 'path'
let g:ctrlp_funky_syntax_highlight = 1

" Spell Check 
let b:myLang=0
let g:myLangList=["nospell", "en_us", "fr"]
function! ToggleSpell()
  let b:myLang=b:myLang+1
  if b:myLang>=len(g:myLangList) | let b:myLang=0 | endif
  if b:myLang==0
    setlocal nospell
  else
    execute "setlocal spell spelllang=".get(g:myLangList, b:myLang)
  endif
  echo "spell checking language:" g:myLangList[b:myLang]
endfunction


" Sudo hack
let g:IgnoreChange=0
autocmd! FileChangedShell *
    \ if 1 == g:IgnoreChange |
    \   let v:fcs_choice="" |
    \   let g:IgnoreChange=0 |
    \ else |
    \   let v:fcs_choice="ask" |
    \ endif
cmap w!! let g:IgnoreChange=1<CR>:w !sudo tee % >/dev/null<CR>:e!<CR>


if has('python')
python << pythoneof
import vim
import os
import ConfigParser

path = os.path.abspath(vim.eval('getcwd()'))
home = os.path.abspath("~")

# Load virtualenv && Read flake8 config from tox if available
while True:
    plist = [p for p in os.listdir(path)
             if p in [ "tox.ini", ".tox", "venv", ".git", ".hg", ".vimrc"]]
    if plist:
        for venv in [".tox/py27", ".tox/py27-postgresql-file", 
                     ".tox/py27-postgresql-ceph", ".tox/py27-mysql-file"]:
            venvdir = os.path.join(path, venv)
            if os.path.exists(venvdir):
                vim.command("let g:pymode_virtualenv = 1")
                vim.command("let g:pymode_virtualenv_path = '%s'" % venvdir)
        if os.path.exists("%s/tox.ini"):
            config = ConfigParser.ConfigParser()
            config.read(['tox.ini'])
            try:
                ignore = config.get('flake8', 'ignore')
            except (ConfigParser.NoOptionError, ConfigParser.NoSectionError):
                pass
            else:
                vim.command("let g:pymode_lint_ignore += '%s'" % ignore)
        break
    
    path = os.path.abspath(os.path.join(path, ".."))
    if path == home:
        break
pythoneof
endif


function! StripTrailingWhitespace()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " do the business:
    %s/\s\+$//e
    " clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

function! InitializeDirectories()
    let parent = $HOME
    let prefix = 'vim'
    let dir_list = {
                \ 'backup': 'backupdir',
                \ 'views': 'viewdir',
                \ 'swap': 'directory' }

    if has('persistent_undo')
        let dir_list['undo'] = 'undodir'
    endif

    " To specify a different directory in which to place the vimbackup,
    " vimviews, vimundo, and vimswap files/directories, add the following to
    " your .vimrc.before.local file:
    "   let g:spf13_consolidated_directory = <full path to desired directory>
    "   eg: let g:spf13_consolidated_directory = $HOME . '/.vim/'
    if exists('g:spf13_consolidated_directory')
        let common_dir = g:spf13_consolidated_directory . prefix
    else
        let common_dir = parent . '/.' . prefix
    endif

    for [dirname, settingname] in items(dir_list)
        let directory = common_dir . dirname . '/'
        if exists("*mkdir")
            if !isdirectory(directory)
                call mkdir(directory)
            endif
        endif
        if !isdirectory(directory)
            echo "Warning: Unable to create backup directory: " . directory
            echo "Try: mkdir -p " . directory
        else
            let directory = substitute(directory, " ", "\\\\ ", "g")
            exec "set " . settingname . "=" . directory
        endif
    endfor
endfunction
call InitializeDirectories()
