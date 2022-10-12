[[ ! -o rcs ]] && return

# automatically remove duplicates from these arrays
typeset -gU path cdpath fpath manpath fignore
autoload -U zmv             # programmable moving, copying, and linking
autoload -U zrecompile      # allow zwc file recompiling
autoload -Uz add-zsh-hook

[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
fpath+=(/opt/homebrew/share/zsh/site-functions)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
HEROKU_AC_ZSH_SETUP_PATH=$HOME/Library/Caches/heroku/autocomplete/zsh_setup && test -f $HEROKU_AC_ZSH_SETUP_PATH && source $HEROKU_AC_ZSH_SETUP_PATH;

# default macos
#export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
# homebrew optional
for gnubin in gnu-sed grep findutils coreutils bash; do
    export PATH="/opt/homebrew/opt/${gnubin}/libexec/gnubin:$PATH"
done
# me
export PATH="$HOME/.bin:$HOME/.env/bin:$HOME/.local/npi/node_modules/.bin:$HOME/.cargo/bin:$PATH"


############
# BINDKEYS #
############

KEYTIMEOUT=1

bindkey -e              # load emacs bindkeys
bindkey " " magic-space # also do history expansion on space

#typeset -g -A key
#
#key[Home]="${terminfo[khome]}"
#key[End]="${terminfo[kend]}"
#key[Insert]="${terminfo[kich1]}"
#key[Backspace]="${terminfo[kbs]}"
#key[Delete]="${terminfo[kdch1]}"
#key[Up]="${terminfo[kcuu1]}"
#key[Down]="${terminfo[kcud1]}"
#key[Left]="${terminfo[kcub1]}"
#key[Right]="${terminfo[kcuf1]}"
#key[PageUp]="${terminfo[kpp]}"
#key[PageDown]="${terminfo[knp]}"
#key[Shift-Tab]="${terminfo[kcbt]}"
#
## setup key accordingly
#[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
#[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
#[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
#[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
#[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
#[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
#[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
#[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
#[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
#[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
#[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
#[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
#
### Finally, make sure the terminal is in application mode, when zle is
### active. Only then are the values from $terminfo valid.
##if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
##	autoload -Uz add-zle-hook-widget
##	function zle_application_mode_start { echoti smkx }
##	function zle_application_mode_stop { echoti rmkx }
##	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
##	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
##fi
#
#
#autoload -U select-word-style
#select-word-style bash
#
###########
# PLUGINS #
###########

#zstyle ':znap:*:*' git-maintenance off
source $HOME/.env/znap/zsh-snap/znap.zsh
znap prompt sindresorhus/pure

zstyle ':completion:*' menu select
##znap source marlonrichert/zsh-autocomplete
znap source zsh-users/zsh-completions

## In-line suggestions
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history )
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c80,)|*\\#:hist:push-line:)'
znap source zsh-users/zsh-autosuggestions

# Command-line syntax highlighting
#ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
##znap source zsh-users/zsh-syntax-highlighting
znap source z-shell/F-Sy-H

znap source ael-code/zsh-colored-man-pages

zmodload -F zsh/parameter p:functions_source

# Better command line editing tools
znap source marlonrichert/zsh-edit
zstyle ':edit:*' word-chars '*?\'

#znap source marlonrichert/zsh-hist  # History editing tools

bind \
    '^[o' 'open .' \
    '^[l' 'git log' \
    '^[s' 'git status -Mu --show-stash'

# Replace some default keybindings with better built-in widgets.
#bindkey \
#    '^[q'   push-line-or-edit \
#    '^V'    vi-quoted-insert

# Alt-Shift-S: Prefix current or previous command line with `sudo`.
.sudo() {
  [[ -z $BUFFER ]] &&
      zle .up-history
  LBUFFER="sudo $LBUFFER"
}
zle -N .sudo
bindkey '^[S' .sudo

znap source marlonrichert/zcolors
znap eval zcolors zcolors

#znap source Aloxaf/fzf-tab

znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'

znap function _python_argcomplete pipx  'eval "$( register-python-argcomplete pipx  )"'
complete -o nospace -o default -o bashdefault -F _python_argcomplete pipx

#znap function _pyenv pyenv              'eval "$( pyenv init - --no-rehash --path)"'
#compctl -K    _pyenv pyenv

znap function _pip_completion pip       'eval "$( pip completion --zsh )"'
compctl -K    _pip_completion pip

zstyle ':autocomplete:*' min-delay 0
zstyle ':autocomplete:*' min-input 2
zstyle ':autocomplete:*' insert-unambiguous yes
# zstyle ':autocomplete:*' widget-style menu-complete
zstyle ':autocomplete:*' widget-style menu-select
# zstyle ':autocomplete:*' widget-style complete-word
# zstyle ':autocomplete:*' fzf-completion yes


PIP_PACKAGES=(
    pipx
    pulsectl
)

PIPX_PACKAGES=(
    git-pull-request
    reno
    rstcheck
    jedi-language-server
)

NPM_PACKAGES=(
    neovim
    lua-fmt
    typescript-language-server
    npm-check-updates
    @taplo/cli
    grammarly-languageserver
    @sentry/cli
    eslint_d
    eslint
    npm-check-updates
    git-split-diffs
    vim-language-server
    yaml-language-server
    stylelint-lsp
    vscode-langservers-extracted
    diagnostic-languageserver
    stylelint
    stylelint-config-standard
    jsonlint
    alex
    fixjson
    prettier
    bash-language-server
    markdownlint
    npm-check-updates
)

#########
# THEME #
#########

PURE_GIT_PULL=0
PURE_GIT_UNTRACKED_DIRTY=0
case $HOST in
    eve) host_color=252;;
    gizmo) host_color=214;;
    billy) host_color=76;;
    joe) host_color=216; PURE_KUBE=1;;
    oberon) host_color=216; PURE_KUBE=1;;
    *) host_color=242;;
esac

zstyle :prompt:pure:git:stash show yes
zstyle :prompt:pure:host color $host_color
zstyle :prompt:pure:user color $host_color

# Cursor style when executing a command
.prompt.cursor.blinking-underline() { print -n '\e[3 q'; true }
add-zsh-hook preexec .prompt.cursor.blinking-underline

 # Cursor style when the command line is active
.prompt.cursor.blinking-bar()       { print -n '\e[5 q'; true }
add-zsh-hook precmd  .prompt.cursor.blinking-bar
.prompt.cursor.blinking-bar

#########
# WATCH #
#########
# this function is launched every $PERIOD seconds
_rehash(){ rehash }
add-zsh-hook periodic _rehash
PERIOD=30
watch=(notme)
LOGCHECK=120
REPORTTIME=5
MAILCHECK=0

###########
# HISTORY #
###########
HISTFILE=$ZVARDIR/history
HISTSIZE=10000
SAVEHIST=$HISTSIZE
LISTMAX=1000
#setopt bang_hist          # treat ! specially like csh did
#setopt hist_ignore_dups   # ignore duplicates in the history
setopt hist_ignore_all_dups  # remove previous command in history in case of duplicates
setopt extended_history      # save timestamp and duration with each event
setopt hist_find_no_dups     # skip over non-contiguous duplicates when searching history
setopt hist_ignore_space     # don't store commands starting with a space in the history file
setopt hist_no_store         # don't store history/fc -l invocations
setopt hist_reduce_blanks    # remove superfluous blanks from each command line
setopt histverify            # when using ! cmds, confirm first

###############
# Interactive #
###############
#setopt extended_glob     # in order to use #, ~ and ^ for filename generation
setopt interactive_comments
#setopt auto_cd         # a commande like % /usr/local is equivalent to cd /usr/local
#setopt autopushd       # automatically append dirs to the push/pop list
#setopt pushdignoredups # and don't duplicate them
#setopt pushd_to_home   # cd go to home
#setopt pushd_minus     # push + -
#setopt pushdsilent
setopt noclobber       # do not clobber files with >
setopt nohup           # don't send HUP signal when closing term session
setopt notify          # report the status of backgrounds jobs immediately
setopt no_bgnice       # do not auto-nice background processes
setopt nocaseglob
setopt rmstarwait      # wait 10 seconds before querying for a rm which contains a *
setopt noflow_control  # desactive ^S/^Q
#setopt printexitvalue  # show the exit-value if > 0
setopt checkjobs       # do alert me of running jobs before exiting
setopt no_bad_pattern  # don't bitch about bad patterns, just use them verbatim
setopt no_nomatch      # don't bitch about no matches, just the glob character verbatim
setopt no_beep         # do. not. ever. beep.
set -C                 # Don't ecrase file with >, use >| (overwrite) or >> (append) instead


##############
# Completion #
##############
#setopt auto_list         # automatically list choices on an ambiguous completion
#setopt auto_menu         # use menu after the second completion request
# setopt rec_exact         # recognise exact matches even if they're ambiguous
# setopt always_to_end     # move cursor to end of word being completed
# setopt correct           # try to correct the spelling if possible
# setopt correctall        # correct all arguments, not just the command
# setopt completeinword    # not just at the end
#setopt chase_dots        # Replace ../ by the right directory
#setopt complete_aliases
#setopt listpacked        # Small list
#setopt extended_glob     # in order to use #, ~ and ^ for filename generation
#setopt auto_param_keys   # be magic about adding/removing final characters on tab completion
#setopt auto_param_slash  # be magic about adding/removing final characters on tab completion
#setopt auto_remove_slash # be magic about adding/removing final characters on tab completion
#zmodload zsh/complist    # load fancy completion list and menu handler

# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZVARDIR/compcache
## allow one error for every three characters typed in approximate completer
#zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
## match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

npi() {
    (
        add-zsh-hook -d chpwd s
        local dir=$HOME/.local/npi
        mkdir -p $dir
        cd $dir
        npm install --no-fund --no-audit --no-save --no-package-lock $NPM_PACKAGES
    )
}
pipxi() {
    (
        add-zsh-hook -d chpwd s
        local dir=$HOME/.local/pipx/venvs/
        local pipx_packages_installed=($(pipx list --short | awk '{print $1}'))
        for package in $pipx_packages_installed ; do
            if [[ $PIPX_PACKAGES[(Ie)$package] -eq 0 ]] ; then
                pipx uninstall $package
            fi
        done
        for package in $PIPX_PACKAGES ; do
            if [ ! -e $dir/$package ]; then
                pipx install $package
            fi
        done
        pipx upgrade-all

    )
}
vimi(){
    (
        nvim --headless -c "autocmd\ User\ PackerComplete\ quitall" -c "PackerSync"
        nvim --headless -c TSUpdateSync -c q
        nvim --headless -c "autocmd\ User\ PackerComplete\ quitall" -c "PackerCompile" -c q
    )
}

snapi() {
    (
        add-zsh-hook -d chpwd s
        (cd ~/.env/znap/zsh-snap && git pull --rebase)
        (cd ~/.env && git commit -m "update znap" --no-edit znap/zsh-snap )
        znap pull
        znap clean
        znap compile
        echo
    )
}

upgrade() {
    (
        add-zsh-hook -d chpwd s
        local title() { echo ; echo "# $1 #" ; echo; }
        title "BREW"
        brew update
        brew upgrade
        title "ENV"
        (cd ~/.env && git diff --quiet && git pull --rebase --recurse-submodules && ./install ) # Only pull if not dirty
        title "ZSNAP"
        snapi 
        title "PIPX"
        pipxi
        title "NPM"
        npi
        title "NVIM"
        vimi
    )
}

function cdt() { cd $(mktemp -d -t cdt.$(date '+%Y%m%d-%H%M%S').XXXXXXXX) ; pwd }
function s() { pwd >| $ZVARDIR/.saved_dir; pwd >| $ZVARDIR/.saved_dir_$$; }
function i() { sp="$(cat $ZVARDIR/.saved_dir 2>/dev/null)"; [ -d $sp -a -r $sp ] && cd $sp }
function ii() { p=$(cat $ZVARDIR/.saved_dir_* | fzf) ; cd $p ; s ; }
function zshexit() {
    rm -f $ZVARDIR/.saved_dir_$$
}
i
add-zsh-hook chpwd s

alias Q='exec zsh'
function sc() { tmux attach -d 2>/dev/null || tmux new-session ; }
if (( $+commands[xdg-open] )) then alias open="xdg-open" ; fi
alias rm="nocorrect rm -i"
alias mv="nocorrect mv -i"
alias cp="nocorrect cp -i"
alias ln='nocorrect ln'
alias mkdir='nocorrect mkdir'
[ ${UID} -eq 0 ] && alias sudo="" || alias sudo="nocorrect sudo"
alias wget='noglob wget'
alias curl='noglob curl --silent'
alias man="LANG=C man"
alias df="df -h"
alias diff='diff -rNu'
alias ip='ip -color'
alias heroku="TERM=xterm heroku"
alias r="ranger"
alias psql="sudo -i -u postgres psql"
function diffv() {
    diff "$@" | git-split-diffs --color=16m | less -RFX
}


# VIM stuff
export EDITOR=nvim
export VISUAL=nvim

function nvim(){
    # Replace :123 by \s+123
    local cmd="command nvim" arg new_arg
	for arg in $@; do
        new_arg=$(echo "$arg" | sed 's/:\([0-9]\+\)\( \|$\)/ +\1\2/g')
        cmd="$cmd $new_arg"
	done
	eval $cmd
}

alias vim="nvim"
alias vi="nvim"
alias svi="sudo -E nvim"

# LESS stuff
export LESS='--quit-if-one-screen --no-init --hilite-search --jump-target=0.5 --SILENT --raw-control-chars'
export LESSHISTFILE=~/.var/less/history
[[ -d ${LESSHISTFILE%/*} ]] || mkdir -p ${LESSHISTFILE%/*}
export PAGER=less
export LESSCOLOR=always
export LESSCOLORIZER="highlight -O ansi"
export LESSOPEN="|lesspipe %s"
alias more=less

# FIND STUFF
alias find='noglob find'
alias qf='find . -iname '

# GREP STUFF
alias sed="gsed"
alias grep="ggrep"
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
function sgrep() {
    local GREP_ARGS=(
      --devices=skip
      --colour=always
      --with-filename
      --line-number
      --dereference-recursive
      --binary-files=without-match
      --exclude-dir=.git
      --exclude-dir=.tags
      --exclude-dir=.bzr
      --exclude-dir=.tox
      --exclude-dir=.svn
      --exclude-dir=.mypy_cache
      --exclude-dir=__pycache__
      --exclude-dir=node_modules
  )
  grep $GREP_ARGS $@
}

# ZSH STUFF
alias zmv="nocorrect noglob zmv"
alias mmv="nocorrect noglob zmv -W"
alias zcp='zmv -C'
alias zln='zmv -L'

alias ls="exa -F --group-directories-first --icons"
#alias ls="LC_COLLATE=POSIX ls -h --color=auto -bCF --group-directories-first"
alias ll="ls -l"
alias lla="ls -la"
alias lsd='ls -ld *(-/DN)'
alias lsdir="for dir in *;do;if [ -d \$dir ];then;du -xhsL \$dir 2>/dev/null;fi;done"
function l(){ lla --color="always" "$@" | more }
function lsp() {
    local p="$(readlink -f ${1:=.})"
    local all_paths
    while [ $p != "/" ]; do
        all_paths=($p $all_paths)
        p=$(dirname $p)
    done
    ll -d --sort=inode $all_paths
}

function fwget(){
    local filename=$(wget -S --spider "$*" 2>&1| grep 'Content-disposition: attachment' | sed -e '/Content-disposition: attachment/s/.*filename="\(.*\)"/\1/g')
    if [ -n "$filename" ] ; then
       wget -O $filename "$*"
    else
       echo " * No attachement found"
    fi
}

# Docker Stuffs
export DOCKER_BUILDKIT=1
diclean () {
    docker images -q -f dangling=true | xargs docker rmi
}
dclean () {
    filter=${1:=whatever}
    for d in $(docker ps -a | grep --color=auto -v -e 'CONTAINER ID' -e " ${filter}_" | awk '{print $1}'); do
        docker stop $d
        docker rm $d
    done
    docker ps -a
}

# SSH stuff
sshclean(){
    hostname=$(echo $1 | sed -e 's/.*@\([^@]*\)/\1/g' -e 's/\.t$/.tetaneutral.net/g')
    for i in $hostname $(getent ahosts $hostname | awk '{print $1}' | sort -u); do
        ssh-keygen -R "$i"
        ssh-keygen -R "[$i]:22"
        ssh-keygen -R "[$i]:2222"
        ssh-keygen -R "[$i]:22222"
        ssh-keygen -R "[$i]:5555"
        ssh-keygen -R "[$i]:55555"
    done
}

sshrefresh(){
    sshclean "$1"
    hostname=$(echo $1 | sed 's/\.t$/.tetaneutral.net/g')
    for i in $hostname $(getent ahosts $hostname | awk '{print $1}' | sort -u); do
        new=$(ssh-keyscan -H "$i")
        if [ -z "$new" ]; then
            new=$(ssh-keyscan -p 2222 -H "$i")
        fi
        [ "$new" ] && echo "$new" >> $HOME/.ssh/known_hosts
    done
}

# Python stuff
function etox() {
    zparseopts -D e+:=env
    typeset -A helper
    helper=($(seq 1 ${#env}))
    rootdir="$(pwd)"
    [ ! -d "$rootdir/.tox" ] && rootdir=".."
    [ ! -d "$rootdir/.tox" ] && rootdir="../.."
    [ ! -d "$rootdir/.tox" ] && rootdir="../../.."
    [ ! -d "$rootdir/.tox" ] && rootdir="../../../.."
    for item in ${(@v)helper}; do
        for e in "${(@s/,/)env[$item]}" ; do
            venv=$rootdir/.tox/$e
            if [ ! -d "$venv" ] ; then
                tox -e $e --notest
            fi
            TOXENV=$(tox --showconfig -e $e | sed -n -e "/^setenv/s/.*SetenvDict: {\(.*\)}/\1/gp" | sed -e "s/, '/\nexport /g" -e "s/': /=/g" -e "s/^'/export /g")
            bash -c "eval $TOXENV ; source $venv/bin/activate ; $*"
        done
    done
}

function utox() {
    zparseopts -D e+:=env
    typeset -A helper
    helper=($(seq 1 ${#env}))
    for item in ${(@v)helper}; do
        for e in "${(@s/,/)env[$item]}" ; do
            etox -e $e "$@" pip install -U pip
            etox -e $e "$@" pip install -U --upgrade-strategy eager -e . $(tox --notest --showconfig | awk '/^\[testenv:'$e'\]$/{while ($1 != "deps") { getline ; }; print $0 ; }' | sed -e 's/\s*deps\s*=\s*\[\(.*\)\]/\1/g' | sed -e 's/, / /g')
        done
    done
}

alias etox="nocorrect etox"
alias utox="nocorrect utox"

function gbe() {
    local n=${1:=-7}
    for p in $HOME/workspace/mergify/engine*; do
        echo "-- $p --";
        (cd $p ; git b $n);
        echo
    done
}
function gbd() {
    local n=${1:=-7}
    for p in $HOME/workspace/mergify/dashboard*; do
        echo "-- $p --";
        (cd $p ; git b $n);
        echo
    done
}

