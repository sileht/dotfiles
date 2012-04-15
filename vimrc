

set nocompatible 
"set title         " Mets le fichier ouvert dans xterm title
set nobackup       " No backup file
set showcmd        " Show (partial) command in status line.
set showmatch      " Show matching brackets.
set ignorecase     " Do case insensitive matching
set smartcase      " Do smart case matching
set incsearch      " Incremental search
set autowrite      " Automatically save before commands like :next and :make
set hidden             " Hide buffers when they are abandoned
"set mouse=a        " Enable mouse usage (all modes) in terminals
"set mousehide
"set nomousefocus
"set mousemodel=extend

set background=dark
"highlight Pmenu      ctermbg=1 guibg=Red
"highlight PmenuSel   ctermbg=2 ctermfg=4 guibg=Green

syntax on
filetype plugin indent on
set modeline

set iskeyword=@,48-57,_,192-255,.
set isfname=@,48-57,/,.,-,_,+,,,#,$,%,~
set wrap

set laststatus=2
set statusline=%<%n:%f%h%m%r%=%{&ff}\ %l,%c%V\ %P

set ruler
set number
""set matchtime=5

"" ** TAB SETTING **
set preserveindent
set softtabstop=4
set shiftwidth=4
set tabstop=4
set expandtab
set shiftround
set autoindent
set textwidth=78
set colorcolumn=+1
set textwidth=0

"set wildmenu
"set wildmode=list:full

" Open file in last read line
if has("autocmd")
  " Open file on 
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
  au BufRead *.py set textwidth=78
endif

match ErrorMsg '\%>80v.+'
" **************
" * KEYBINDING *
" **************

" Map key to toggle opt
function MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command -nargs=+ MapToggle call MapToggle(<f-args>)

map!  

noremap H :set hlsearch!<CR>

" Q command to reformat paragraphs and list.
nnoremap Q gq} 
" W command to delete trailing white space and Dos-returns 
" and to expand tabs to spaces.
nnoremap W :%s/[\r \t]\+$//<CR>:set et<CR>:retab!<CR>

" Display-altering option toggles
MapToggle <F2> wrap
MapToggle <F3> list
map <F4> :call SortLine()

map <F5> :call ChangeTextwitdth()
map <F6> :w<CR>:!aspell -c %<CR>:e %<CR>
MapToggle <F7> paste
map <F8> :call ChangeKeyword()
MapToggle <F9> hlsearch

" Behavior-altering option toggles
MapToggle <F10> scrollbind
MapToggle <F11> ignorecase

" *****************
" Some function ***
" *****************

function ChangeKeyword()
    if &iskeyword == "@,48-57,_,192-255,."
        set iskeyword=@,48-57,_,192-255
        echo "iskeyword=@,48-57,_,192-255"
    else
        set iskeyword=@,48-57,_,192-255,.
        echo "iskeyword=@,48-57,_,192-255,."
    endif
endfunction

function ChangeTextwitdth()
    if &textwidth == "0"
        set textwidth=78 
        echo "textwidth=78"
    else
        set textwidth=0
        echo "textwidth=0"
    endif
endfunction

" For USE ligne in gentoo
function SortLine()
    let line = getline('.')
    let l:words = split(split(line,' \')[0], ' ')
    let l:words = sort(l:words)
    call setline(".", join(l:words, ' ').' \')
endfunction

" ******************
" Some key maps  ***
" ******************
fun! CompleteEmails(findstart, base)
    if a:findstart
        let line = getline('.')
        "locate the start of the word
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '[^:,]'
            let start -= 1
        endwhile
        return start
    else
        " find the addresses ustig the external tool
        " the tools must give properly formated email addresses
        let res = []
        "let search_term = shellescape(substitute(@a:base,"^\\s\\+\\|\\s\\+$","","g"))
        for m in split(system('pc_query -m "' . shellescape(a:base) . '"'),'\n')
                call add(res, m)
        endfor
        return res
    endif
endfun

fun! UserComplete(findstart, base)
    " Fetch current line
    let line = getline(line('.'))
    " Is it a special line?
    if line =~ '^\(To\|Cc\|Bcc\|From\|Reply-To\):'
        return CompleteEmails(a:findstart, a:base)
    endif
endfun

set completefunc=UserComplete


