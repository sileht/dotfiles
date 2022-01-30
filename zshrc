[[ ! -o rcs ]] && return

# source ~/.creds

[ -f /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
[ -f $HOME/.iterm2_shell_integration.zsh ] && source $HOME/.iterm2_shell_integration.zsh
fpath+=(/opt/homebrew/share/zsh/site-functions)

# automatically remove duplicates from these arrays
typeset -gU path cdpath fpath manpath fignore

autoload -U zmv             # programmable moving, copying, and linking
autoload -U zrecompile      # allow zwc file recompiling
autoload -Uz add-zsh-hook

############
# BINDKEYS #
############
bindkey -e              # load emacs bindkeys
bindkey " " magic-space # also do history expansion on space

typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}" ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi


autoload -U select-word-style
select-word-style bash

###########
# PLUGINS #
###########

zstyle ':znap:*:*' git-maintenance off
if [ -d /workspaces/.codespaces/.persistedshare/dotfiles ]; then
    source /workspaces/.codespaces/.persistedshare/dotfiles/znap/zsh-snap/znap.zsh
else
    source ~/.env/znap/zsh-snap/znap.zsh
fi
znap prompt sindresorhus/pure

zstyle ':completion:*' menu select
#znap source marlonrichert/zsh-autocomplete
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-completions
znap source marlonrichert/zcolors
znap eval zcolors zcolors

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
    poetry
    git-pull-request
    reno
    rstcheck
    jedi-language-server
    dmypy-ls
    flake8-ls
)

NPM_PACKAGES=(
    typescript-language-server
    npm-check-updates
    @taplo/cli
    @emacs-grammarly/unofficial-grammarly-language-server
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

colormode() {
    local mode="${1:=eighties}"
    source ~/.env/base16-shell/scripts/base16-${mode}.sh
    echo "colorscheme base16-${mode}" >| ~/.vimrc_background
    echo "${mode}" >| ~/.colormode
}
alias lightmode="colormode one-light"
#alias darkmode="colormode eighties"
alias darkmode="colormode snazzy"
_last_colormode="$(cat ~/.colormode 2>/dev/null)"
colormode "$_last_colormode"

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

#zrecompile ~/.zprofile ~/.zshenv ~/.zshrc | while read pre file post; do
#    case "$post" in
#      succeeded) rm -f "${file%:}".old;;
#      *) :;;
#    esac
#  done


#zcompileall(){
#    for file in ~/.zprofile ~/.zshenv ~/.zshrc ; do
#        rm -f $file.zwc
#        rm -f $file.zwc.old
#        zcompile $file
#    done
#}

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
        for package in $PIPX_PACKAGES ; do
            if [ ! -e $dir/$package ]; then
                pipx install $package
            fi
        done

    )
}

upgrade() {
    (
        add-zsh-hook -d chpwd s
        local title() { echo ; echo "# $1 #" ; echo; }
        if (( $+commands[brew] )); then
            title "BREW"
            brew update
        fi
        if (( $+commands[pacman] )); then
            title "PACMAN"
            (yes | sudo pacman -Suy)
            sudo remove-orphaned-kernels
            sudo pacman -Rns $(pacman -Qtdq)
            sudo paccache -ruk0
            pkill -f polybar-update.sh
            title "PIP"
            python3 -m pip install -q -U --user $PIP_PACKAGES
        fi
        title "ENV"
        (cd ~/.env && git diff --quiet && git pull --rebase --recurse-submodules && ./install ) # Only pull if not dirty
        title "ZSNAP"
        (cd ~/.env/znap/zsh-snap && git pull --rebase)
        (cd ~/.env && git commit -m "update znap" --no-edit znap/zsh-snap )
        znap pull
        echo
        title "PIPX"
        pipx upgrade-all
        pipxi
        title "NPM"
        npi
        if (( $+commands[bin] )) then
            title "BIN"
            bin update -y
        fi
        title "NVIM"
        nvim --headless -c "autocmd\ User\ PackerComplete\ quitall" -c "PackerSync"
    )
}

mka () { time schedtool -B -n 1 -e ionice -n 1 make -j $(nproc) "$@" }
imka () { time schedtool -D -n 19 -e ionice -c 3 make -j $(nproc) "$@" }
masq (){ sudo iptables -t nat -A POSTROUTING -s "$1" ! -d "$1" -j MASQUERADE }
ban(){ sudo iptables -I INPUT 1 -s "$1" -j DROP }
unban(){ sudo iptables -D INPUT -s "$1" -j DROP }
alias idletask='schedtool -D -n 19 -e ionice -c 3'
alias batchtask='schedtool -B -n 1 -e ionice -n 1'

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
#alias sc="screen -RDD"
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
alias optimutt="find ~/.mutt/cache/headers -type f -exec tcbmgr optimize -nl {} \;"
alias heroku="TERM=xterm heroku"
function diffv() {
    diff "$@" | git-split-diffs --color=16m | less -RFX
}

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
alias r="ranger"
alias psql="sudo -i -u postgres psql"
# alias pyclean='find . \( -type f -name "*.py[co]" \) -o \( -type d -path "*__pycache__*" \) ! -path "./.tox*" -delete"'
alias pyclean='find . \( -type f -name "*.py[co]" \) ! -path "./.tox*" -delete'
alias more=less

# FIND STUFF
alias locate='noglob locate'
alias find='noglob find'
alias qf='find . -iname '

# GREP STUFF
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
alias xclip="xclip -selection c"

alias ls="exa -F --group-directories-first"
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
        [ "$new" ] && echo "$new" >> /home/sileht/.ssh/known_hosts
    done
}

update-widevine() {
    rm -f ~/.local/lib/libwidevinecdm.so
    widevine_version="$(wget -q -O- https://dl.google.com/widevine-cdm/current.txt)"
    wget -q "https://dl.google.com/widevine-cdm/${widevine_version}-linux-x64.zip" -O- | busybox unzip - -d ~/.local/lib libwidevinecdm.so
}

#alias tox="eatmydata tox";

function etox() {
    zparseopts -D e+:=env
    typeset -A helper
    helper=($(seq 1 ${#env}))
    rootdir="$(pwd)"
    [ ! -d "$rootdir/.tox" ] && rootdir=".."
    [ ! -d "$rootdir/.tox" ] && rootdir="../.."
    [ ! -d "$rootdir/.tox" ] && rootdir="../../.."
    [ ! -d "$rootdir/.tox" ] && rootdir="../../../.."
    export OLDPATH=$PATH
    for item in ${(@v)helper}; do
        for e in "${(@s/,/)env[$item]}" ; do
            export VIRTUAL_ENV=$rootdir/.tox/$e
            if [ ! -d "$VIRTUAL_ENV" ] ; then
                tox -e$e --notest
            fi
            source $VIRTUAL_ENV/bin/activate
            #eatmydata $*
            $*
            deactivate
        done
    done
    export PATH=$OLDPATH
    unset OLDPATH
    unset VIRTUAL_ENV
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

##########
# SCREEN #
##########

__ssh_auth_sock_fix() {
    # Predictable SSH authentication socket location.
    local SOCK="/tmp/ssh-agent-$USER-screen"
    if [ -e "$SSH_AUTH_SOCK" -a "$SSH_AUTH_SOCK" != "$SOCK" ]; then
        rm -f /tmp/ssh-agent-$USER-screen
        ln -sf $SSH_AUTH_SOCK $SOCK
        export SSH_AUTH_SOCK=$SOCK
    fi
}

# precmd_functions+=(__ssh_auth_sock_fix)
__ssh_auth_sock_fix

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

