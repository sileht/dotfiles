

" Reload .vimrc on write
"autocmd BufWritePost .vimrc source ~/.vimrc

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

" Open file in last read line
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal g'\"" | endif
  au BufRead ks.cfg* set ft=cfg
  au BufRead *.spec noremap <F7> /%changelog<cr>:r!LANG=C date +"\%a \%b \%d \%Y"<CR>I* <esc>A Mehdi ABAAKOUK <mehdi.abaakouk@regis-dgac.net><CR>Release <esc>/Version:<cr>$T v$hy/Release <cr>$pa-<esc>/Release:<cr>$T v$hy/Release <cr>$po-
  au BufRead lisez-moi.txt noremap <F7> Go<esc>:r!date +"\%d/\%m/\%Y"<CR>ILe <esc>A (MAB)<CR>-
endif

set modeline

set iskeyword=@,48-57,_,192-255,.
set isfname=@,48-57,/,.,-,_,+,,,#,$,%,~

set laststatus=2
set statusline=%<%n:%f%h%m%r%=%{&ff}\ %l,%c%V\ %P


"set ruler
""set nowrap
""set matchtime=5

"" ** TAB SETTING **
set preserveindent
set softtabstop=4
set shiftwidth=4
set tabstop=4
"set expandtab
set shiftround
"set wildmode=list:full

"set noequalalways

"set textwidth=78
set autoindent
"set wildmenu


" ***********************
" *** PLUGINS SETTING ***
" ***********************

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

map!  
"map O3B :bp
"map O3A :bn
"map O1;3B :bp
"map O1;3A :bn

noremap H :set hlsearch!<CR>

inoremap  
inoremap  

" Q command to reformat paragraphs and list.
nnoremap Q gq} 
" W command to delete trailing white space and Dos-returns and to expand tabs to spaces.
nnoremap W :%s/[\r \t]\+$//<CR>:set et<CR>:retab!<CR>

" Map key to toggle opt
function MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
command -nargs=+ MapToggle call MapToggle(<f-args>)

map <F4> :buffers
map <F5> :bp
map <F6> :bn
MapToggle <F7> paste
set pastetoggle=<F7>
map <F8> :call ChangeKeyword()
MapToggle <F9> hlsearch

" Display-altering option toggles
"MapToggle <F2> wrap
"MapToggle <F3> list

" Behavior-altering option toggles
"MapToggle <F10> scrollbind
"MapToggle <F11> ignorecase


vmap <F12> :<C-U>!firefox "http://www.google.fr/search?hl=fr&q=<cword>&btnG=Recherche+Google&meta=" >& /dev/null<CR><CR>
map <F11> :w<CR>:!aspell -c %<CR>:e %<CR>

map <F3> :call SortLine()



