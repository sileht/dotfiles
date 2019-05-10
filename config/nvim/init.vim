set nocompatible

" Temp hack for https://github.com/neovim/neovim/issues/3211
map <F1> <del>
map! <F1> <del>

" Add some missing filetype extentions
autocmd BufNewFile,BufRead *.yaml set filetype=yml
autocmd BufNewFile,BufRead *.j2	  set filetype=jinja
autocmd BufNewFile,BufRead *mutt-* set filetype=mail
autocmd BufNewFile,BufRead rest.j2	  set filetype=rst

call plug#begin('~/.local/share/nvim/plugged')

" Style
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'mhinz/vim-signify'                " VCS diff
Plug 'tpope/vim-fugitive'               " GIT
Plug 'ryanoasis/vim-devicons'
Plug 'eugen0329/vim-esearch'
Plug 'lambdalisue/suda.vim'
" Text navigation
Plug 'nacitar/terminalkeys.vim'
Plug 'junegunn/vim-easy-align'
" File/Tag browsing
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tacahiroy/ctrlp-funky'

Plug 'lilydjwg/colorizer'       " color hexa code (eg: #0F12AB)
Plug 'luochen1990/rainbow'      " special parenthesis colors
Plug 'inside/vim-search-pulse'

" Language
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
Plug 'jaxbot/semantic-highlight.vim'                                  " semantic highlight (permanent)
" Can be replaced by coc-highlight
Plug 'numirias/semshi',               {'do': ':UpdateRemotePlugins'}  " semantic highlight (selected)

Plug 'dbeniamine/vim-mail',           {'for': 'mail'}

call plug#end()


set encoding=utf8
scriptencoding utf-8
syntax on
filetype plugin indent on
set shell=/bin/sh

"set clipboard=unnamed,unnamedplus
set mouse=r
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

" http://snk.tuxfamily.org/log/vim-256color-bce.html
" Disable Background Color Erase (BCE) so that color schemes
" work properly when Vim is used inside tmux and GNU screen.
if &term =~ '256color'
  set t_ut=
endif

nnoremap P "0p                            " Paste last yank
nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
nmap <silent> <leader>/ :nohlsearch<CR>   " Clean hlsearch on new search
command! Notes execute "help mynotes"
command! R execute "source ~/.vimrc"

" ###############
" ### ON LOAD ###
" ###############

" Change cwd to file directory
autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
" Cut at 80 for some filetype
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rst set textwidth=79
" No ending space
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rst,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> call StripTrailingWhitespace()
" libvirt C style
autocmd BufWritePre,BufRead *.c setlocal smartindent cindent cinoptions=(0,:0,l1,t0,L3
autocmd BufWritePre,BufRead *.h setlocal smartindent cindent cinoptions=(0,:0,l1,t0,L3

match ErrorMsg /\s\+$\| \+\ze\t/

"" Restore cursor position
if (&ft!='mail')
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
endif

autocmd CursorHold * silent call CocActionAsync('highlight')

" ##############
" ### Themes ###
" ##############
set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
set background=dark
let g:gruvbox_italic=1
"let g:gruvbox_contrast_dark="hard"
let g:gruvbox_improved_warnings=1
let g:gruvbox_guisp_fallback='bg'
colorscheme gruvbox

set cursorline
set laststatus=2        " Show statusbar

" ###############
" ### AIRLINE ###
" ###############
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_theme = 'bubblegum'
let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

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

" ###########
" ### COC ###
" ###########

set hidden          " if hidden is not set, TextEdit might fail.
set cmdheight=2     " Better display for messages
set updatetime=300  " Smaller updatetime for CursorHold & CursorHoldI
set shortmess+=c    " don't give |ins-completion-menu| messages.

let g:coc_force_debug = 1

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> for trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for format selected region
vmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)


" ############
" ### JEDI ###
" ############

" Use system python for neovim itself
let g:python_host_prog = '/usr/bin/python'
let g:python3_host_prog = '/usr/bin/python3'

" ##################
" ### EASY ALIGN ###
" ##################

xmap ga <Plug>(EasyAlign)    " Start interactive EasyAlign in visual mode (e.g. vipga)
nmap ga <Plug>(EasyAlign)    " Start interactive EasyAlign for a motion/text object (e.g. gaip)

" #############
" ### CTRLP ###
" #############

let g:ctrlp_funky_matchtype = 'path'
let g:ctrlp_funky_syntax_highlight = 1
nnoremap <C-e> :CtrlPFunky<Cr>
nnoremap <C-E> :execute 'CtrlPFunky ' . expand('<cword>')<Cr>

" ##############
" ### Semshi ###
" ##############
"
nmap <silent> <leader>rr :Semshi rename<CR>
nmap <silent> <Tab> :Semshi goto name next<CR>
nmap <silent> <S-Tab> :Semshi goto name prev<CR>
nmap <silent> <leader>c :Semshi goto class next<CR>
nmap <silent> <leader>C :Semshi goto class prev<CR>
nmap <silent> <leader>f :Semshi goto function next<CR>
nmap <silent> <leader>F :Semshi goto function prev<CR>
nmap <silent> <leader>ee :Semshi error<CR>
nmap <silent> <leader>ge :Semshi goto error<CR>

" #####################
" ### OTHER PLUGINS ###
" #####################

let g:semanticTermColors = [28,1,2,3,4,5,6,7,25,9,10,34,12,13,14,15,125,124,19]
nnoremap <F10> :SemanticHighlightToggle<cr>
"autocmd FileType * SemanticHighlightToggle

cmap w!! :w suda://%<CR>:e!<CR>

let g:signify_update_on_focusgained = 1
let g:vim_search_pulse_duration = 200
let g:rubycomplete_buffer_loading = 1
let g:rainbow_active = 1

au FileType spec map <buffer> <F5> <Plug>AddChangelogEntry
let spec_chglog_packager = "Mehdi Abaakouk <sileht@redhat.com>"

" ############
" ### Mail ###
" ############
let g:VimMailSpellLangs=['fr', 'en']
let g:VimMailClient="true"
let g:VimMailStartFlags="SA"
let g:VimMailContactSyncCmd="true"
let g:VimMailContactQueryCmd="/home/sileht/.env/bin/vim-mail-contact-query"
autocmd FileType mail setlocal completeopt+=preview
autocmd BufWritePre,BufRead *.c setlocal shiftwidth=2 expandtab tabstop=2 softtabstop=2
autocmd BufWritePre,BufRead *.h setlocal shiftwidth=2 expandtab tabstop=2 softtabstop=2

" ###################
" ### SPELL CHECK ###
" ###################
" Use en_us spell and completion per default for markdown and rst
autocmd FileType gitcommit,rst,mkd,markdown,jinja silent! call ToggleSpell()
autocmd FileType gitcommit,rst,mkd,markdown,jinja set complete+=kspell

map <F6> :w<CR>:!aspell -l en -c %<CR>:e %<CR>
map <F7> :w<CR>:!aspell -l fr -c %<CR>:e %<CR>
nmap <silent> <F8> :call ToggleSpell()<CR>

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

" #########################
" ### VARIOUS FUNCTIONS ###
" #########################
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
    let dir_list = {'backup': 'backupdir','views': 'viewdir', 'swap': 'directory' }

    " To specify a different directory in which to place the vimbackup,
    " vimviews, vimundo, and vimswap files/directories, add the following to
    " your .vimrc.before.local file:
    "   let g:spf13_consolidated_directory = <full path to desired directory>
    "   eg: let g:spf13_consolidated_directory = $HOME . '/.vim/'
    let common_dir = parent . '/.' . prefix

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

function! LoadVirtualEnv()
if has('python')
python << pythoneof
import vim
import os

def load_flake8(path):
    venvdir = os.path.join(path, ".tox/pep8")
    if os.path.exists(venvdir):
        vim.command("let g:ale_python_flake8_executable = '%s/bin/flake8'" % venvdir)

def load_venv(path):
    for venv in (".tox/py36", ".tox/py37", ".tox/py27", ".tox/py27-postgresql-file", ".tox/py27-mysql-file", "venv"):
        venvdir = os.path.join(path, venv)
        if os.path.exists(venvdir):
            vim.command("let $VIRTUAL_ENV='%s'" % venvdir)
            return

def is_source_root(path):
    for f in ("tox.ini", ".tox", "venv", ".git", ".hg"):
        if os.path.exists(os.path.join(path, f)):
            return True
    return False

current_path = os.path.abspath(vim.eval('getcwd()'))
home = os.path.abspath("~")
while True:
    if is_source_root(current_path):
        load_venv(current_path)
        load_flake8(current_path)
        break
    current_path = os.path.abspath(os.path.join(current_path, ".."))
    if current_path == home or current_path == "/":
        break

pythoneof
endif
endfunction
