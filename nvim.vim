set nocompatible


" Add some missing filetype extentions
autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
autocmd BufNewFile,BufRead *.yaml  set filetype=yml
autocmd BufNewFile,BufRead *.j2	   set filetype=jinja
autocmd BufNewFile,BufRead *.kt set filetype=kotlin

call plug#begin('~/.local/share/nvim/plugged')

" Style
Plug 'chriskempson/base16-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'bling/vim-bufferline'
Plug 'ryanoasis/vim-devicons'
Plug 'eugen0329/vim-esearch'
Plug 'lambdalisue/suda.vim'
" Text navigation
Plug 'nacitar/terminalkeys.vim'
Plug 'junegunn/vim-easy-align'
" File/Tag browsing
Plug 'tmux-plugins/vim-tmux-focus-events'

Plug 'rhysd/vim-grammarous'

Plug 'liuchengxu/vim-clap'

Plug 'lilydjwg/colorizer'       " color hexa code (eg: #0F12AB)
Plug 'luochen1990/rainbow'      " special parenthesis colors
Plug 'inside/vim-search-pulse'
Plug 'brooth/far.vim'

" Language
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sheerun/vim-polyglot'

call plug#end()


set encoding=utf8
scriptencoding utf-8
syntax on
filetype plugin indent on
set shell=/bin/sh

"set clipboard=unnamed,unnamedplus
set mouse=
set hidden                      " Allow buffer switching without saving
"set backup                      " Backups are nice ...
set nobackup
set nowritebackup

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

let mapleader = ","
let g:mapleader = ","
let maplocalleader = ";"
let g:maplocalleader = ";"

" http://snk.tuxfamily.org/log/vim-256color-bce.html
" Disable Background Color Erase (BCE) so that color schemes
" work properly when Vim is used inside tmux and GNU screen.
if &term =~ '256color'
  set t_ut=
endif

nnoremap P "0p                            " Paste last yank
nnoremap Y y$                             " Yank from the cursor to the end of the line, to be consistent with C and D.
nmap <silent> <leader>/ :nohlsearch<CR>   " Clean hlsearch on new search
command! R execute "source ~/.config/nvim/init.vim"

" ###############
" ### ON LOAD ###
" ###############

" Cut at 80 for some filetype
"autocmd FileType c,cpp,java,go,php,javascript,javascriptreact,puppet,rst set textwidth=79
"autocmd FileType python set textwidth=90

" libvirt C style, skip me if editorconfig is present ?
"autocmd BufWritePre,BufRead *.c setlocal smartindent cindent cinoptions=(0,:0,l1,t0,L3
"autocmd BufWritePre,BufRead *.h setlocal smartindent cindent cinoptions=(0,:0,l1,t0,L3

""autocmd BufWritePre,BufRead *.cpp setlocal shiftwidth=4 expandtab tabstop=4 softtabstop=4
""autocmd BufWritePre,BufRead *.c setlocal shiftwidth=4 expandtab tabstop=4 softtabstop=4
""autocmd BufWritePre,BufRead *.h setlocal shiftwidth=4 expandtab tabstop=4 softtabstop=4

" Javascript people like 2 chars sep
"autocmd FileType javascript,javascriptreact set shiftwidth=2 tabstop=4 softtabstop=4

"autocmd BufWritePre *.py call CocAction('runCommand', 'editor.action.organizeImport')
"autocmd BufWritePre *.py call CocAction('format')

match ErrorMsg /\s\+$\| \+\ze\t/

" ##############
" ### Themes ###
" ##############
"set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
let base16colorspace=256
if filereadable(expand("~/.vimrc_background"))
  source ~/.vimrc_background
else
  colorscheme base16-eighties
endif


set cursorline
set laststatus=2        " Show statusbar

" ###############
" ### AIRLINE ###
" ###############
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
let g:airline#extensions#coc#enabled = 1
let g:airline_theme = 'base16_eighties'

nmap <leader>& <Plug>AirlineSelectTab1
nmap <leader>é <Plug>AirlineSelectTab2
nmap <leader>" <Plug>AirlineSelectTab3
nmap <leader>' <Plug>AirlineSelectTab4
nmap <leader>( <Plug>AirlineSelectTab5
nmap <leader>- <Plug>AirlineSelectTab6
nmap <leader>è <Plug>AirlineSelectTab7
nmap <leader>_ <Plug>AirlineSelectTab8
nmap <leader>ç <Plug>AirlineSelectTab9

nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
nmap <S-left>  <Plug>AirlineSelectPrevTab
nmap <S-right> <Plug>AirlineSelectNextTab

" ###########
" ### COC ###
" ###########

set cmdheight=2
set shortmess+=c
set signcolumn=number  " merge signcolumn and number column into one

let g:coc_global_extensions = ['coc-eslint', 'coc-json', 'coc-git', 'coc-pyright', 'coc-tsserver', 'coc-html']

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current buffer.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" ##################
" ### EASY ALIGN ###
" ##################

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" #####################
" ### OTHER PLUGINS ###
" #####################

let g:semanticTermColors = [28,1,2,3,4,5,6,7,25,9,10,34,12,13,14,15,125,124,19]
nnoremap <F10> :SemanticHighlightToggle<cr>
" autocmd FileType * SemanticHighlightToggle

nnoremap <C-o> :Clap files<cr>
nnoremap <C-f> :Clap grep<cr>

cmap w!! :w suda://%<CR>:e!<CR>

let g:signify_update_on_focusgained = 1
let g:vim_search_pulse_duration = 200
let g:rainbow_active = 1

au FileType spec map <buffer> <F5> <Plug>AddChangelogEntry
let spec_chglog_packager = "Mehdi Abaakouk <sileht@sileht.net>"

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

function! SetProjectRoot()
  " default to the current file's directory
  lcd %:p:h
  let git_dir = trim(system("git rev-parse --show-toplevel"))
  let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
  if empty(is_not_git_dir)
    for p in [".tox/py39", ".tox/py38", ".tox/py37", ".tox/py27", "venv"]
      if isdirectory(git_dir."/".p)
        call coc#config("python.pythonPath", git_dir."/".p."/bin/python")
        break
      endif
    endfor
  endif
endfunction

" follow symlink and set working directory
autocmd BufEnter * call SetProjectRoot()

"" netrw: follow symlink and set working directory
"autocmd CursorMoved silent *
"  " short circuit for non-netrw files
"  \ if &filetype == 'netrw' |
"  \   call FollowSymlink() |
"  \   call SetProjectRoot() |
"  \ endif

packloadall
silent! helptags ALL
