set nocompatible

" Add some missing filetype extentions
autocmd BufNewFile,BufRead *.jsx set filetype=javascript.jsx
autocmd BufNewFile,BufRead *.yaml set filetype=yaml
autocmd BufNewFile,BufRead *.j2	  set filetype=jinja

call plug#begin('~/.local/share/nvim/plugged')

" Style
Plug 'chriskempson/base16-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
Plug 'mengelbrecht/lightline-bufferline'
Plug 'daviesjamie/vim-base16-lightline'
Plug 'ryanoasis/vim-devicons'
Plug 'lambdalisue/suda.vim'
" Text navigation
Plug 'nacitar/terminalkeys.vim'
Plug 'junegunn/vim-easy-align'
" File/Tag browsing
Plug 'tmux-plugins/vim-tmux-focus-events'
" Plug 'psliwka/vim-smoothie'
Plug 'joeytwiddle/sexy_scroller.vim'

Plug 'tpope/vim-dotenv'

Plug 'rhysd/vim-grammarous'

Plug 'liuchengxu/vim-clap'      " CTRL+o

Plug 'lilydjwg/colorizer'       " color hexa code (eg: #0F12AB)
Plug 'luochen1990/rainbow'      " special parenthesis colors
Plug 'inside/vim-search-pulse'

" Language
Plug 'dense-analysis/ale'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'tbodt/deoplete-tabnine', { 'do': './install.sh' }

"Plug 'fszymanski/deoplete-emoji'
Plug 'dpelle/vim-Grammalecte'
Plug 'tpope/vim-rhubarb'        " GitHub ticket completion
"Plug 'sileht/vim-linear'       " Linear ticket completion
Plug '~/workspace/sileht/vim-linear/'

Plug 'sheerun/vim-polyglot'     " Syntax highlight for all languages

Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-signify'

Plug 'junegunn/vim-github-dashboard'
Plug 'lifepillar/vim-cheat40'
"Plug 'github/copilot.vim'

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

autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
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
"set showtabline=2       " Show tabline

" #################
" ### LIGHTLINE ###
" #################
let g:lightline#bufferline#number_separator = ':'
let g:lightline#bufferline#icon_position    = 'right'
let g:lightline#bufferline#show_number      = 1
let g:lightline#bufferline#shorten_path     = 1
let g:lightline#bufferline#unicode_symbols  = 1
let g:lightline#bufferline#unnamed          = '[No Name]'
let g:lightline#bufferline#enable_devicons  = 1
let g:lightline#bufferline#number_map       = {
\ 0: '⁰', 1: '¹', 2: '²', 3: '³', 4: '⁴',
\ 5: '⁵', 6: '⁶', 7: '⁷', 8: '⁸', 9: '⁹'}
"let g:lightline#bufferline#composed_number_map = {
"\ 1:  '⑴ ', 2:  '⑵ ', 3:  '⑶ ', 4:  '⑷ ', 5:  '⑸ ',
"\ 6:  '⑹ ', 7:  '⑺ ', 8:  '⑻ ', 9:  '⑼ ', 10: '⑽ ',
"\ 11: '⑾ ', 12: '⑿ ', 13: '⒀ ', 14: '⒁ ', 15: '⒂ ',
"\ 16: '⒃ ', 17: '⒄ ', 18: '⒅ ', 19: '⒆ ', 20: '⒇ '}

let g:lightline                    = {}
let g:lightline.colorscheme        = 'base16'
let g:lightline.active             = {}
let g:lightline.active.left        = [['mode', 'paste', 'readonly', 'modified', 'buffers']]
let g:lightline.active.right       = [['lineinfo'], ['percent'], ['gitbranch', 'fileformat', 'fileencoding', 'filetype']]
let g:lightline.inactive           = {}
let g:lightline.inactive.left      = [['filename']]
let g:lightline.inactive.right     = [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype']]
let g:lightline.component_expand   = {'buffers': 'lightline#bufferline#buffers'}
let g:lightline.component_type     = {'buffers': 'tabsel'}
let g:lightline.separator          = { 'left': "\ue0b0", 'right': "\ue0b2" }
let g:lightline.subseparator       = { 'left': "\ue0b1", 'right': "\ue0b3" }
let g:lightline.component_function = { 'gitbranch': 'FugitiveHead' }

nmap <Leader>1 <Plug>lightline#bufferline#go(1)
nmap <Leader>2 <Plug>lightline#bufferline#go(2)
nmap <Leader>3 <Plug>lightline#bufferline#go(3)
nmap <Leader>4 <Plug>lightline#bufferline#go(4)
nmap <Leader>5 <Plug>lightline#bufferline#go(5)
nmap <Leader>6 <Plug>lightline#bufferline#go(6)
nmap <Leader>7 <Plug>lightline#bufferline#go(7)
nmap <Leader>8 <Plug>lightline#bufferline#go(8)
nmap <Leader>9 <Plug>lightline#bufferline#go(9)
nmap <Leader>0 <Plug>lightline#bufferline#go(10)
nmap <Leader>c1 <Plug>lightline#bufferline#delete(1)
nmap <Leader>c2 <Plug>lightline#bufferline#delete(2)
nmap <Leader>c3 <Plug>lightline#bufferline#delete(3)
nmap <Leader>c4 <Plug>lightline#bufferline#delete(4)
nmap <Leader>c5 <Plug>lightline#bufferline#delete(5)
nmap <Leader>c6 <Plug>lightline#bufferline#delete(6)
nmap <Leader>c7 <Plug>lightline#bufferline#delete(7)
nmap <Leader>c8 <Plug>lightline#bufferline#delete(8)
nmap <Leader>c9 <Plug>lightline#bufferline#delete(9)
nmap <Leader>c0 <Plug>lightline#bufferline#delete(10)
nmap <S-left>  :bprevious<Enter>
nmap <S-right> :bnext<Enter>
autocmd BufWritePost,TextChanged,TextChangedI * call lightline#update()

" ###########
" ### ALE ###
" ###########


" Only use errors and fixers reporting of ALE
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('sources', {
    \ '_': ['ale'],
    \})
"'tabnine', 'emoji'],
"
let g:ale_completion_enabled = 0
let g:ale_fix_on_save = 0
let g:ale_fixers = {}
let g:ale_fixers['*'] = ['remove_trailing_lines', 'trim_whitespace']
let g:ale_fixers.javascript = ['eslint']
let g:ale_fixers.jsx = ['eslint']
let g:ale_fixers.python = ["isort", "black"]
let g:ale_fixers.json = ['fixjson', 'jq']

let g:ale_linters = {}
let g:ale_linters.sh = ['language_server']
let g:ale_linters.markdown = ['vale', 'alex', 'markdownlint']
let g:ale_linters.rst = ['vale', 'alex', 'rstcheck']
let g:ale_linters.yaml = ['yamllint']
let g:ale_linters.text = ['vale']
let g:ale_linters.asciidoc = ['vale']
let g:ale_linters.vim = ['vimls']
let g:ale_linters.json = ['jsonlint', 'jq']
let g:ale_linters.python = ['jedils', 'flake8', 'mypy']
let g:ale_linters.javascript = ['stylelint', 'eslint']
let g:ale_linters.css = ["stylelint"]
let g:ale_linter_aliases = {}
let g:ale_linter_aliases.jsx = ['css', 'javascript']
let g:ale_linter_aliases.gitcommit = ['text']

"copen " open quickfix list on startup
"let g:ale_set_balloons = 1
"let g:ale_hover_to_floating_preview = 1
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0
let g:ale_open_list = 1
"autocmd BufUnload * if empty(&bt) | lclose | endif
let g:ale_list_window_size = 5
let g:ale_keep_list_window_open = 0
let g:ale_set_highlights = 0

let g:ale_lint_on_text_changed = 'never'
" let g:ale_lint_on_insert_leave = 0
" let g:ale_lint_on_enter = 0

let g:ale_echo_msg_error_str = '⛔'
let g:ale_echo_msg_warning_str = '⚠'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

let g:ale_sign_column_always = 1  " always show left column
let g:ale_sign_error = '⛔'
let g:ale_sign_info = 'ℹ'
let g:ale_sign_offset = 1000000
let g:ale_sign_style_error = '⛔'
let g:ale_sign_style_warning = '⚠'
let g:ale_sign_warning = '⚠'

function! ALESearch()
    call inputsave()
    let search = input('Search symbol: ', expand('<cword>'))
    call inputrestore()
    execute "ALESymbolSearch ".search
endfunction

nmap <silent> <F4> :GrammarousCheck<CR>
nmap <silent> <F5> :ALERename<CR>
nmap <silent> <F6> :ALEGoToDefinition<CR>
nmap <silent> <F7> :ALEFindReferences<CR>
nmap <silent> <F8> :call ALESearch()<CR>
nmap <silent> <leader>r :ALERename<CR>
nmap <silent> <leader>d :ALEGoToDefinition<CR>
nmap <silent> <leader>s :ALEFindReferences<CR>

" ##################
" ### EASY ALIGN ###
" ##################

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

" #####################
" ### OTHER PLUGINS ###
" #####################

"nnoremap <C-m> :Clap quickfix<cr>
nnoremap <C-p> :Clap grep2<cr>
nnoremap <C-o> :Clap gfiles<cr>

cmap w!! :w suda://%<CR>:e!<CR>

source ~/.creds.vimrc
"let g:LINEAR_STATE_IDS = ["22f2b6eb-f794-4cc7-8212-ad0094d16a2a"] 
"let g:LINEAR_STATE_IDS = ["cdd327d2-7875-4636-ba9d-adccf335d888"]

let g:github_dashboard = { 'username': 'sileht', 'password': g:GITHUB_TOKEN }
let g:signify_update_on_focusgained = 1
let g:vim_search_pulse_duration = 200
let g:rainbow_active = 1

function! MyOmni(findstart, base) abort
    let s:linear_items = linear#Complete(a:findstart, a:base)
    return s:linear_items
    "let s:gh_items = rhubarb#Complete(a:findstart, a:base)
    return s:linear_items + s:gh_items
endfunction
autocmd FileType gitcommit setlocal omnifunc=MyOmni

" ###################
" ### SPELL CHECK ###
" ###################
" Use en_us spell and completion per default for markdown and rst
autocmd FileType gitcommit,rst,mkd,markdown,jinja silent! call ToggleSpell()
autocmd FileType gitcommit,rst,mkd,markdown,jinja set complete+=kspell


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

nmap <silent> <F9> :call ToggleSpell()<CR>
" #########################
" ### VARIOUS FUNCTIONS ###
" #########################
function! InitializeDirectories()
    let parent = $HOME
    let prefix = 'vim'
    let dir_list = {'backup': 'backupdir','views': 'viewdir', 'swap': 'directory' }
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

function! CommandInBuffer(name, cmd)
    function! s:OnEvent(job_id, data, event) dict
        if a:event == 'stdout'
            echom a:data[0]
        elseif a:event == 'stderr'
            echom a:data[0]
        else
            echom self.name." finished"
        endif
    endfunction
    let s:callbacks = {
    \ 'on_stdout': function('s:OnEvent'),
    \ 'on_stderr': function('s:OnEvent'),
    \ 'on_exit': function('s:OnEvent')
    \ }
    let job = jobstart(a:cmd, extend({'name': a:name}, s:callbacks))
endfunction

function! SetProjectRoot()
  " default to the current file's directory
  lcd %:p:h
  let git_dir = trim(system("git rev-parse --show-toplevel"))
  let is_not_git_dir = matchstr(git_dir, '^fatal:.*')
  if empty(is_not_git_dir) && isdirectory(git_dir."/.tox/pep8")
    let b:ale_fix_on_save = 1
    if expand('%:e') == "py"
      let b:ale_python_jedils_executable = git_dir."/.tox/pep8/bin/jedi-language-server"
      let b:ale_python_mypy_executable = git_dir."/.tox/pep8/bin/mypy"
      let b:ale_python_flake8_executable = git_dir."/.tox/pep8/bin/flake8"
      let b:ale_python_black_executable = git_dir."/.tox/pep8/bin/black"
      let b:ale_python_isort_executable = git_dir."/.tox/pep8/bin/isort"
      let packages = []
      for package in ["jedi-language-server"]
          if !filereadable(git_dir."/.tox/pep8/bin/".package)
              call add(packages, package)
          endif
      endfor
      if len(packages)
          let pip_cmd = "pip install ".join(packages, " ")
          let full_pip_cmd = git_dir."/.tox/pep8/bin/".pip_cmd
          call CommandInBuffer(pip_cmd, full_pip_cmd)
      endif
    endif

    if expand('%:e') == "yaml"
      let b:ale_yaml_yamllint_options = "-c ".git_dir."/.yamllint.yml"
    endif

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
