[[ ! -o rcs ]] && return



export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8

export AWS_PROFILE=mergify-admin

# automatically remove duplicates from these arrays
typeset -gU path cdpath fpath manpath fignore
autoload -U zmv             # programmable moving, copying, and linking
autoload -U zrecompile      # allow zwc file recompiling
autoload -Uz add-zsh-hook

export HOMEBREW_NO_ANALYTICS=1
BREW_PREFIX=/opt/homebrew

# default macos
#export PATH="$HOME/.local/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

[ -f ${BREW_PREFIX}/bin/brew ] && eval "$(${BREW_PREFIX}/bin/brew shellenv)"
fpath+=(${BREW_PREFIX}/share/zsh/site-functions)

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# znap adds ~/.local/bin
source $HOME/.env/znap/zsh-snap/znap.zsh

source ~/.orbstack/shell/init.zsh
source "${BREW_PREFIX}/share/google-cloud-sdk/path.zsh.inc"
source "${BREW_PREFIX}/share/google-cloud-sdk/completion.zsh.inc"

# homebrew optional
for gnubin in gnu-sed grep findutils coreutils bash; do
    export PATH="${BREW_PREFIX}/opt/${gnubin}/libexec/gnubin:$PATH"
done
# me
export PATH="$HOME/.bin:$HOME/.local/bin:$HOME/.env/bin:$HOME/.local/npi/node_modules/.bin:$HOME/.cargo/bin:$PATH"

# export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin/"
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="$PATH:/Users/sileht/workspace/mergify/oss/mergiraf/target/release"
export PATH="/opt/homebrew/opt/openjdk@21/bin:$PATH"

export NODE_OPTIONS="--max-old-space-size=18192" # --trace-deprecation --trace-warnings"
export NODE_NO_WARNINGS=1

export JAVA_HOME=/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home

export PYTEST_XDIST_AUTO_NUM_WORKERS=5

eval "$(fzf --zsh)"
export FZF_DEFAULT_OPTS='--height 30% --layout=reverse --no-separator --no-scrollbar --info=hidden --pointer="|" --prompt="➠ "'

############
# BINDKEYS #
############

KEYTIMEOUT=1

bindkey -e              # load emacs bindkeys
bindkey " " magic-space # also do history expansion on space

###########
# PLUGINS #
###########

zstyle ':znap:*:*' git-maintenance off
# znap prompt sindresorhus/pure
autoload -U promptinit; promptinit
prompt pure


zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZVARDIR/compcache
## allow one error for every three characters typed in approximate completer
#zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
## match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

znap source zsh-users/zsh-completions

# Command-line syntax highlighting
#ZSH_HIGHLIGHT_HIGHLIGHTERS=( main brackets )
##znap source zsh-users/zsh-syntax-highlighting
znap source z-shell/F-Sy-H

# In-line suggestions
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=()
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS+=( forward-char forward-word end-of-line )
ZSH_AUTOSUGGEST_STRATEGY=( history )
ZSH_AUTOSUGGEST_HISTORY_IGNORE=$'(*\n*|?(#c80,)|*\\#:hist:push-line:)'
znap source zsh-users/zsh-autosuggestions


export GREP_COLOR='mt=$GREP_COLOR'


PIPX_PACKAGES=(
    reno
    jedi-language-server
    poetry
    poethepoet
    neovim-remote
    neovim
    # ddev
)

NPM_PACKAGES=(
    @github/local-action
    @anthropic-ai/claude-code
    squawk-cli
    npm-check-updates
    @redocly/cli@latest
    svgexport
    @biomejs/biome
    diagnostic-languageserver
    @microsoft/compose-language-service
    @github/copilot-language-server
    dockerfile-language-server-nodejs
    wrangler
    serve
    neovim
    lua-fmt
    typescript
    typescript-language-server
    grammarly-languageserver
    @sentry/cli
    vscode-langservers-extracted
    vim-language-server
    yaml-language-server
    jsonlint
    prettier
    bash-language-server
    markdownlint
    @vtsls/language-server
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
zstyle :prompt:pure:git:fetch only_upstream yes
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
HISTSIZE=100000
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



macos_finder_setup() {
    local EXTS=xml json yaml yml md txt html css js ts tsx go py rb php java c cpp h sh zsh bash fish dockerfile
    for ext in $EXTS; do
        duti -s com.apple.automator.Nvim $ext all
    done
}

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
                if [ $package != "mergify_cli" ]; then
                    pipx uninstall $package
                fi
            fi
        done
        for package in $PIPX_PACKAGES ; do
            if [ ! -e $dir/$package ]; then
                if [ $package == "ddev" ]; then
                    pipx install ddev --python ${BREW_PREFIX}/bin/python3.8
                else
                    pipx install $package
                fi
            fi
        done
        pipx upgrade-all

    )
}
vimi(){
    (
        command nvim -c "lua require('lazy').sync({wait=1})" -c "sleep 100m" -c "qa"
        nvim --headless -c TSUpdateSync -c q
    )
}

snapi() {
    (
        add-zsh-hook -d chpwd s
        (cd ~/.env/znap/zsh-snap && git pull --rebase)
        (cd ~/.env && git commit -m "update znap" --no-edit znap/zsh-snap )
        znap pull
        znap clean ~/.env ~/.local/zsh* ~/.cache/zsh*
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
        # brow update
        # brow upgrade
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
alias r="ranger"
function diffv() {
    diff "$@" | git-split-diffs --color=16m | less -RFX
}

# VIM stuff
export EDITOR=nvim
export VISUAL=nvim

function nvim2(){
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
export LESS='--quit-if-one-screen --no-init --hilite-search --SILENT --raw-control-chars --jump-target=2'
export LESSHISTFILE=~/.var/less/history
[[ -d ${LESSHISTFILE%/*} ]] || mkdir -p ${LESSHISTFILE%/*}
export PAGER=less
export LESSCOLOR=always
export LESSCOLORIZER="highlight -O ansi"
export LESSOPEN="|lesspipe %s"
alias more=$PAGER

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
      --exclude-dir=.venv
      --exclude-dir=.mypy_cache
      --exclude-dir=__pycache__
      --exclude-dir=public-config-schemas
      --exclude-dir=public-api-schemas
      --exclude-dir=node_modules
      --exclude=mergify.schema.*\.ts
      --exclude=mergify.schema.*\.js
  )
  grep $GREP_ARGS $@
}

# ZSH STUFF
alias zmv="nocorrect noglob zmv"
alias mmv="nocorrect noglob zmv -W"
alias zcp='zmv -C'
alias zln='zmv -L'


alias ls='eza $eza_params'
alias l='eza --git-ignore --long $eza_params'
alias ll='eza --all --header --long $eza_params'
alias llm='eza --all --header --long --sort=modified $eza_params'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree $eza_params'
alias tree='eza --tree $eza_params'

function lsp() {
    local p="$(readlink -f ${1:=.})"
    local all_paths
    while [ $p != "/" ]; do
        all_paths=($p $all_paths)
        p=$(dirname $p)
    done
    eza --all --header --long $eza_params  -d --sort=inode $all_paths
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

function get-env-secret () {
    security find-generic-password -w -s "ENV_${1}"
}
function export-secret() {
    env="$1"
    secret="$(get-env-secret $env)"
    export "$env=$secret"
}

# Use: set-keychain-environment-variable SECRET_ENV_VAR
#   provide: super_secret_key_abc123
function set-env-secret () {
    [ -n "$1" ] || print "Missing environment variable name"
    
    # Note: if using bash, use `-p` to indicate a prompt string, rather than the leading `?`
    read -s "?Enter Value for ${1}: " secret
    
    ( [ -n "$1" ] && [ -n "$secret" ] ) || return 1
    security add-generic-password -U -a "${USER}" -D "environment variable" -s "ENV_${1}" -w "${secret}"
}



if [[ $1 == eval ]]; then
    "$@"
    set --
fi
