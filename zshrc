[[ ! -o rcs ]] && return

# source ~/.creds

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

if [ -d /workspaces/.codespaces/.persistedshare/dotfiles ]; then
    source /workspaces/.codespaces/.persistedshare/dotfiles/znap/zsh-snap/znap.zsh
else
    source ~/.env/znap/zsh-snap/znap.zsh
fi
znap prompt sindresorhus/pure

alias -s whatevertomakeautocomplehappy=nvim
znap source marlonrichert/zsh-autocomplete
znap source marlonrichert/zcolors
znap eval zcolors zcolors

#znap source zdharma-continuum/fast-syntax-highlighting
#znap source zdharma-continuum/history-search-multi-word

znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-autosuggestions
#znap install ogham/exa
#znap source zsh-users/zsh-history-substring-search

znap function _python_argcomplete pipx  'eval "$( register-python-argcomplete pipx  )"'
complete -o nospace -o default -o bashdefault -F _python_argcomplete pipx

#znap function _pyenv pyenv              'eval "$( pyenv init - --no-rehash --path)"'
#compctl -K    _pyenv pyenv

znap function _pip_completion pip       'eval "$( pip completion --zsh )"'
compctl -K    _pip_completion pip

zstyle ':autocomplete:*' min-delay 0.2
zstyle ':autocomplete:*' min-input 0
#zstyle ':autocomplete:*' widget-style menu-complete

#    node'git-split-diffs;
#        vim-language-server;
#        stylelint;
#        stylelint-config-standard;
#        jsonlint;
#        alex;
#        fixjson;
#        prettier;
#        bash-language-server;
#        markdownlint' \
#    sbin'p:venv/bin/git-pull-request;
#        n:node_modules/.bin/markdown-it;
#        n:node_modules/.bin/alex;
#        n:node_modules/.bin/fixjson;
#        n:node_modules/.bin/prettier;
#        n:node_modules/.bin/stylelint;
#        n:node_modules/.bin/jsonlint;
#        n:node_modules/.bin/bash-language-server;
#        n:node_modules/.bin/git-split-diffs;
#        n:node_modules/.bin/vim-language-server'
#zinit load zdharma-continuum/null

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
alias darkmode="colormode snazzy" #eighties"
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
setopt hist_ignore_dups   # ignore duplicates in the history
setopt extended_history   # save timestamp and duration with each event
setopt hist_find_no_dups  # skip over non-contiguous duplicates when searching history
setopt hist_ignore_space  # don't store commands starting with a space in the history file
setopt hist_no_store      # don't store history/fc -l invocations
setopt hist_reduce_blanks # remove superfluous blanks from each command line
setopt histverify         # when using ! cmds, confirm first

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
setopt rec_exact         # recognise exact matches even if they're ambiguous
setopt always_to_end     # move cursor to end of word being completed
setopt correct           # try to correct the spelling if possible
setopt correctall        # correct all arguments, not just the command
setopt completeinword    # not just at the end
setopt always_to_end     # move to cursor to the end after completion
#setopt chase_dots        # Replace ../ by the right directory
#setopt complete_aliases
#setopt listpacked        # Small list
#setopt extended_glob     # in order to use #, ~ and ^ for filename generation
#setopt auto_param_keys   # be magic about adding/removing final characters on tab completion
#setopt auto_param_slash  # be magic about adding/removing final characters on tab completion
#setopt auto_remove_slash # be magic about adding/removing final characters on tab completion
zmodload zsh/complist    # load fancy completion list and menu handler

# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZVARDIR/compcache
## allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
## match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

zrecompile ~/.zprofile ~/.zshenv ~/.zlogin ~/.zlogout ~/.zshrc | while read pre file post; do
    case "$post" in
      succeeded) rm -f "${file%:}".old;;
      *) :;;
    esac
  done


zcompileall(){
    for file in ~/.zprofile ~/.zshenv ~/.zlogin ~/.zlogout ~/.zshrc ; do
        rm -f $file.zwc
        rm -f $file.zwc.old
        zcompile $file
    done
}

upgrade() {
    (yes | sudo pacman -Suy)
    sudo remove-orphaned-kernels
    sudo pacman -Rns $(pacman -Qtdq)
    sudo paccache -ruk0
    pkill -f polybar-update.sh
    (cd ~/.env && git diff --quiet && git pull --rebase --recurse-submodules && ./install ) # Only pull if not dirty
    (cd ~/.env/znap/zsh-snap && git pull --rebase)
    (cd ~/.env && git commit -m "update znap" --no-edit znap/zsh-snap )
    znap pull
    pipx upgrade-all
    nvim "+set nomore" +PlugClean! +PlugUpdate! +qall
}

mka () { time schedtool -B -n 1 -e ionice -n 1 make -j $(nproc) "$@" }
imka () { time schedtool -D -n 19 -e ionice -c 3 make -j $(nproc) "$@" }
masq (){ sudo iptables -t nat -A POSTROUTING -s "$1" ! -d "$1" -j MASQUERADE }
ban(){ sudo iptables -I INPUT 1 -s "$1" -j DROP }
unban(){ sudo iptables -D INPUT -s "$1" -j DROP }
alias idletask='schedtool -D -n 19 -e ionice -c 3'
alias batchtask='schedtool -B -n 1 -e ionice -n 1'

function cdt() { cd $(mktemp -td cdt.$(date '+%Y%m%d-%H%M%S').XXXXXXXX) ; pwd }
function s() { pwd >| $ZVARDIR/.saved_dir; pwd >| $ZVARDIR/.saved_dir_$$; }
function i() { sp="$(cat $ZVARDIR/.saved_dir 2>/dev/null)"; [ -d $sp -a -r $sp ] && cd $sp }
function ii() { p=$(cat $ZVARDIR/.saved_dir_* | fzf) ; cd $p ; s ; }
function zshexit() {
    rm -f $ZVARDIR/.saved_dir_$$
}
function p() {
    local -a working_dirs=($(ls -1d ~/workspace/*/${1}*/.git/.. | sed -e 's@/\.git/\.\./@@g'))
    if [ ${#working_dirs[@]} -eq 1 ] ; then
        cd "${working_dirs}" ; s ; return
    else
        for wd in ${working_dirs[@]}; do
            if [ "$(basename $wd)" == "${1}" ]; then
                cd "$wd"; s; return
            fi
        done
        select wd in ${working_dirs[@]}; do
            cd "$wd"; s; return
        done
    fi
}
i
add-zsh-hook chpwd s

alias Q='exec zsh'
#alias sc="screen -RDD"
function sc() { tmux attach -d 2>/dev/null || tmux new-session ; }
alias open="xdg-open"
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
alias getaptkey='sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com'
alias more=less

# FIND STUFF
alias locate='noglob locate'
alias find='noglob find'
alias qf='find . -iname '
function sfind(){ find "$@" | egrep -v '(Binary|binaire|\.svn|\.git|\.bzr)' ; }

# GREP STUFF
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
function sgrep(){ grep "$@" --color=always 2>&1| grep -v -e 'binary' -e binaire -e '\.svn'  -e '\.git/' -e '\.bzr/' -e '\.mypy_cache/' -e 'node_modules/' -e '.tox/'; }
function g(){ sgrep "$@" | more }

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

# CD STUFF
function cd () {
if [[ -z $2 ]]; then
  if [[ -f $1 ]]; then
    builtin cd $1:h
  else
    if [[ $1 = ".." ]]; then
        new_pwd=${PWD%/*}
        [ -z "$new_pwd" ] && new_pwd="/"
        builtin cd $new_pwd
    else
        builtin cd $1
    fi
  fi
else
  if [[ -z $3 ]]; then
    builtin cd $1 $2
  else
    echo cd: too many arguments
  fi
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

alias tox="eatmydata tox";

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
            eatmydata $*
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
alias upip="pip install -U --upgrade-strategy eager"

function sgpg(){
    gpg_run_path=$(gpgconf --list-dirs socketdir)
    if [ -L $gpg_run_path/S.gpg-agent ]; then
        echo "* gpg-agent uses local systemd sockets"
        rm -rf $gpg_run_path
        systemctl --user start gpg-agent.socket gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket dirmngr.socket gpg-agent.service
    else
        echo "* gpg-agent uses ssh forwarded sockets"
        systemctl --user stop gpg-agent.socket gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket dirmngr.socket gpg-agent.service
        rm -rf $gpg_run_path
        source ~/.zlogin
    fi
}
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

INSIDE_TMUX_SCREEN="$WINDOW$TMUX_PANE"
if [ "$HOST" == "gizmo" -a ! "$INSIDE_TMUX_SCREEN" ]; then
    sc ; exit 0;
fi
