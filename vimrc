set nocompatible

" Temp hack for https://github.com/neovim/neovim/issues/3211
map <F1> <del>
map! <F1> <del>

call plug#begin('~/.vim/plugged')

" Style
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/syntastic'
Plug 'bling/vim-bufferline'
Plug 'mhinz/vim-signify'                " VCS diff
Plug 'tpope/vim-fugitive'               " GIT
Plug 'ryanoasis/vim-devicons'
Plug 'eugen0329/vim-esearch'
" Text navigation
Plug 'nacitar/terminalkeys.vim'
Plug 'junegunn/vim-easy-align'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
"Plug 'wikitopian/hardmode'
" File/Tag browsing
"Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tacahiroy/ctrlp-funky'
Plug 'majutsushi/tagbar'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on':  'NERDTreeToggle' }
Plug 'ervandew/supertab'
" Language
if has('nvim')
Plug 'Shougo/deoplete.nvim',          { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go',             {'for': 'go'}
Plug 'zchee/deoplete-jedi',           {'for': 'python'}
else
Plug 'fatih/vim-go',                  {'for': 'go', 'do': ':GoInstallBinaries'}
Plug 'davidhalter/jedi-vim',          {'for': 'python'}
endif
Plug 'Vimjas/vim-python-pep8-indent', {'for': 'python'}
Plug 'hdima/python-syntax',           {'for': 'python'}

Plug 'vim-scripts/spec.vim',          {'for': 'spec'}
Plug 'godlygeek/tabular'
Plug 'spf13/PIV',                     {'for': 'php'}
Plug 'Rykka/riv.vim',                 {'for': 'rst'}
Plug 'rodjek/vim-puppet',             {'for': 'puppet'}
Plug 'pangloss/vim-javascript',       {'for': 'javascript'}
Plug 'groenewege/vim-less',           {'for': 'less'}
Plug 'elzr/vim-json',                 {'for': 'json'}
Plug 'tpope/vim-rails',               {'for': 'ruby'}
Plug 'tpope/vim-markdown',            {'for': 'markdown'}
Plug 'racer-rust/vim-racer'           " rust
"Plug 'saltstack/salt-vim'            " Salt
Plug 'vim-scripts/HTML-AutoCloseTag', {'for': ['html', 'xml']}
Plug 'hail2u/vim-css3-syntax',        {'for': 'css'}
Plug 'breard-r/vim-dnsserial'         " dns zones
Plug 'leafgarland/typescript-vim',    {'for': ['ts', 'ts.d']}

" Org Mode
"Plug 'jceb/vim-orgmode'
"Plug 'vim-scripts/SyntaxRange'
"Plug 'mattn/calendar-vim'
"Plug 'tpope/vim-speeddating'
"Plug 'chrisbra/NrrwRgn'
"Plug 'vim-scripts/utl.vim'
call plug#end()

if has('nvim')
call deoplete#enable()
endif

set encoding=utf8
scriptencoding utf-8
syntax on
filetype plugin indent on
set shell=/bin/sh

"set clipboard=unnamed,unnamedplus
set mouse=
set hidden                      " Allow buffer switching without saving
set backup                      " Backups are nice ...
set undofile                    " So is persistent undo ...
set undolevels=1000             " Maximum number of changes that can be undone
set undoreload=10000            " Maximum number lines to save for undo on a buffer reload
set backspace=indent,eol,start  " Backspace for dummies
set linespace=0                 " No extra spaces between rows
"set number                      " Line numbers on
"set relativenumber              " 0 is current line
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
syn spell toplevel              " Spell rst issue https://github.com/Rykka/riv.vim/issues/8
set nohlsearch

set guioptions-=M  "remove menu bar
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar

set ttimeout
set ttimeoutlen=50

let mapleader = " "
let g:mapleader = " "
let maplocalleader = ","
let g:maplocalleader = ","

let g:org_agenda_files = ['~/org/index.org']

" Paste last yank
nnoremap P "0p
" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$
" Clean hlsearch on new search
nmap <silent> <leader>/ :nohlsearch<CR>

map <C-n> :NERDTreeToggle<CR>
map <leader>e :NERDTreeFind<CR>
nmap <leader>nt :NERDTreeFind<CR>

map <F6> :w<CR>:!aspell -l en -c %<CR>:e %<CR>
map <F7> :w<CR>:!aspell -l fr -c %<CR>:e %<CR>
nmap <silent> <F8> :call ToggleSpell()<CR>
"nmap <C-e> :TagbarToggle<CR>

" http://snk.tuxfamily.org/log/vim-256color-bce.html
" Disable Background Color Erase (BCE) so that color schemes
" work properly when Vim is used inside tmux and GNU screen.
if &term =~ '256color'
  set t_ut=
endif
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

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

"""""""""""
" On load "
"""""""""""

" Add some missing filetype extentions
autocmd BufNewFile,BufRead *.yaml set filetype=yml

" Change cwd to file directory
autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

" Cut at 80 for some filetype
"autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rst set colorcolumn=80
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rst set textwidth=79

" No ending space
"autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rst,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> call StripTrailingWhitespace()

" Use en_us spell and completion per default for markdown and rst 
autocmd FileType gitcommit,rst,mkd,markdown silent! call ToggleSpell()
autocmd FileType gitcommit,rst,mkd,markdown set complete+=kspell

" No more keypad!
"let g:HardMode_level = 'wannabe'
"autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()

" No jedi-vim doc popup
autocmd FileType python setlocal completeopt-=preview
autocmd FileType python silent! call LoadVenv()

"let g:qcc_query_command='~/.mutt/editor-email-query'
"au BufRead /tmp/mutt* setlocal omnifunc=QueryCommandComplete "<C-X><C-O> 
au BufRead /tmp/mutt* setlocal textwidth=72
au BufRead /tmp/mutt* setlocal wrap
au BufRead /tmp/mutt* setlocal fo+=aw
au BufRead /tmp/mutt* setlocal spell spelllang=fr,en
au BufRead /tmp/mutt* setlocal nocp
"au BufRead /tmp/mutt* startinsert
au BufRead /tmp/mutt* ?^$

" libvirt C style
autocmd BufWritePre,BufRead *.c setlocal smartindent cindent cinoptions=(0,:0,l1,t0,L3
autocmd BufWritePre,BufRead *.h setlocal smartindent cindent cinoptions=(0,:0,l1,t0,L3
"au FileType make setlocal noexpandtab tapstop=8
"au BufRead,BufNewFile *.am setlocal noexpandtab tapstop=8
match ErrorMsg /\s\+$\| \+\ze\t/

" Dirty js format
" autocmd BufWritePre,BufRead *.js :set tabstop=2 shiftwidth=2

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
"let g:gruvbox_contrast_dark="hard"
let g:gruvbox_improved_warnings=1
let g:gruvbox_guisp_fallback='bg'
colorscheme gruvbox

set cursorline
set laststatus=2        " Show statusbar

"""""""""""""""
" Plug config "
"""""""""""""""
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline_theme = 'bubblegum'

let g:jedi#show_call_signatures = "2"    " workaround for https://github.com/davidhalter/jedi-vim/issues/493

let g:signify_update_on_focusgained = 1

let g:riv_global_leader ='<C-s>'
let g:riv_disable_folding = 1

let g:syntastic_c_checkers = []

let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_quiet_messages = {"regex": [ 'W503', 'E402', 'E731', 'H301']}
let g:syntastic_python_flake8_exec = 'myflake8'

let g:syntastic_typescript_checks=['tsc', 'tslint']

let g:syntastic_quiet_messages = {"regex": [ '\mUnknown interpreted text role "doc"' ]}
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_aggregate_errors = 1
let g:syntastic_loc_list_height = 5

"let g:syntastic_debug = 3

let NERDTreeShowBookmarks=1
let NERDTreeIgnore = ['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
let NERDTreeChDirMode=0
let NERDTreeQuitOnOpen=1
let NERDTreeMouseMode=2
let NERDTreeShowHidden=1
let NERDTreeKeepTreeInNewTab=1
let g:nerdtree_tabs_open_on_gui_startup=0

let g:rubycomplete_buffer_loading = 1

let python_highlight_all = 1

let g:ctrlp_funky_matchtype = 'path'
let g:ctrlp_funky_syntax_highlight = 1

let g:deoplete#enable_at_startup = 1

let spec_chglog_packager = "Mehdi Abaakouk <sileht@redhat.com>"
au FileType spec map <buffer> <F5> <Plug>AddChangelogEntry

command! Notes execute "help mynotes"
command! Reload execute "source ~/.vimrc"

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


function! LoadVenv()
if has('python')
python << pythoneof
import vim
import os

path = os.path.abspath(vim.eval('getcwd()'))
home = os.path.abspath("~")

# Load virtualenv && Read flake8 config from tox if available
while True:
    rootfound = [p for p in os.listdir(path)
                 if p in [ "tox.ini", ".tox", "venv", ".git", ".hg", ".vimrc"]]
    if rootfound:
        vim.command("let g:syntastic_python_flake8_args = '\"%s\"'" % path)
        for venv in [".tox/py27-postgresql-file",
                     ".tox/py27-postgresql-ceph", ".tox/py27-mysql-file",
                     ".tox/py27"]:
            venvdir = os.path.join(path, venv)
            if os.path.exists(venvdir):
                vim.command("let g:deoplete#sources#jedi#python_path = '%s/bin/python'" % venvdir)
                break
        if os.path.exists("%s/doc/source" % path):
            vim.command("let g:riv_projects = [{'path': '%s/doc/source',}]" %
                        path)
        break

    path = os.path.abspath(os.path.join(path, ".."))
    if path == home or path == "/":
        break
pythoneof
endif
endfunction

" Use system python for neovim itself
let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'

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
