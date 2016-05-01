[[ ! -o rcs ]] && return

# automatically remove duplicates from these arrays
typeset -gU path cdpath fpath manpath fignore 
typeset -ga preexec_functions
typeset -ga postcmd_functions
typeset -ga precmd_functions
typeset -ga chpwd_functions
typeset -ga periodic_functions

autoload -U zargs           # smart xargs replacement
autoload -U zmv             # programmable moving, copying, and linking
autoload -U colors ; colors # make color arrays available
autoload -U zrecompile      # allow zwc file recompiling
autoload -U allopt          # add command allopt to show all opts

setopt extended_glob     # in order to use #, ~ and ^ for filename generation
zrecompile ~/.zprofile ~/.zshenv ~/.zlogin ~/.zlogout ~/.zshrc ~/.env/zsh-completions/src/*~*.(zwc|old) | while read pre file post; do
    case "$post" in
      succeeded) rm -f "${file%:}".old;;
      *) :;;
    esac
  done


zcompileall(){
    for file in ~/.zprofile ~/.zshenv ~/.zlogin ~/.zlogout ~/.zshrc ~/.env/zsh-completions/src/*~*.(zwc|old) ; do
        rm -f $file.zwc
        rm -f $file.zwc.old
        zcompile $file
    done
}

##########
# SCREEN #
##########

screen_data_file="$HOME/.var/screen_data.$(hostname)"

screen() { store_screen_data ; /usr/bin/screen "$@" ; }
kc(){ eval $(keychain -q --eval --agents ssh --nogui --inherit any --ignore-missing id_rsa ~/.ssh/id_dsa_h1) ; }
update_screen_data(){ [ -r $screen_data_file ] && source $screen_data_file ; }
store_screen_data(){
    export | grep '\(GPG_AGENT_INFO\|DISPLAY\|XAUTHORITY\|SSH_AGENT_PID\|SSH_AUTH_SOCK\|GNOME_KEYRING_PID\|GNOME_KEYRING_SOCKET\)=' | sed -e 's/^/export /g' >| $screen_data_file
}
if [ -n "$WINDOW" ]; then
    update_screen_data
    # Update variable on each zsh in a screen
    preexec_functions+=update_screen_data
elif [ "$HOST" = "gizmo" ]; then
    kc
    screen -RDD ; exit 0
fi


#########
# WATCH #
#########
# this function is launched every $PERIODIC seconds
periodic_functions+=rehash
export PERIOD=30
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
setopt bang_hist          # treat ! specially like csh did
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
setopt INTERACTIVE_COMMENTS
setopt auto_cd         # a commande like % /usr/local is equivalent to cd /usr/local
setopt autopushd       # automatically append dirs to the push/pop list
setopt pushdignoredups # and don't duplicate them
setopt pushd_to_home   # cd go to home
setopt pushd_minus     # push + -
setopt pushdsilent
setopt noclobber       # do not clobber files with >
setopt nohup           # don't send HUP signal when closing term session
setopt notify          # report the status of backgrounds jobs immediately
setopt no_bgnice       # do not auto-nice background processes
setopt nocaseglob
setopt rmstarwait      # wait 10 seconds before querying for a rm which contains a *
setopt noflow_control  # desactive ^S/^Q
setopt printexitvalue  # show the exit-value if > 0
setopt checkjobs       # do alert me of running jobs before exiting
setopt no_bad_pattern  # don't bitch about bad patterns, just use them verbatim
setopt no_nomatch      # don't bitch about no matches, just the glob character verbatim
setopt no_beep         # do. not. ever. beep.
set -C                 # Don't ecrase file with >, use >| (overwrite) or >> (append) instead

# automatically escape URLs
# /usr/share/zsh*/functions/Zle/url-quote-magic
autoload -U url-quote-magic
zle -N self-insert url-quote-magic

# bindkeys
bindkey -e              # load emacs bindkeys
bindkey " " magic-space # also do history expansion on space
for map in emacs viins vicmd; do
    bindkey -M "$map" "${terminfo[kpp]}" "up-line-or-history"
    bindkey -M "$map" "${terminfo[knp]}" "down-line-or-history"
done; unset map

autoload -U zed                           # what, your shell can't edit files?
autoload -U select-word-style
autoload -U backward-kill-word-bash-match
autoload -U edit-command-line             # later bound to C-z e
select-word-style bash

function backward-kill-word-bash-match(){
	autoload backward-kill-word-match
	select-word-style normal
	backward-kill-word-match
	select-word-style bash
}
zle -N backward-kill-word-bash backward-kill-word-bash-match
zle -N edit-command-line
bindkey "" backward-kill-word-bash
bindkey "" edit-command-line
bindkey "e" edit-command-line

##############
# Completion #
##############
setopt auto_list         # automatically list choices on an ambiguous completion
setopt auto_menu         # use menu after the second completion request
setopt rec_exact         # recognise exact matches even if they're ambiguous
setopt always_to_end     # move cursor to end of word being completed
setopt correct           # try to correct the spelling if possible
setopt correctall        # correct all arguments, not just the command
setopt completeinword    # not just at the end
setopt always_to_end     # move to cursor to the end after completion
setopt chase_dots        # Replace ../ by the right directory
setopt complete_aliases
setopt listpacked        # Small list
setopt extended_glob     # in order to use #, ~ and ^ for filename generation
setopt auto_param_keys   # be magic about adding/removing final characters on tab completion
setopt auto_param_slash  # be magic about adding/removing final characters on tab completion
setopt auto_remove_slash # be magic about adding/removing final characters on tab completion
zmodload zsh/complist    # load fancy completion list and menu handler

# initialise the completion system
autoload -U compinit
compinit -C -d $ZVARDIR/comp-$HOST


# Use cache
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZVARDIR/compcache

# list of completers to use
#zstyle ':completion:*' completer _list _expand _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*::::' completer _complete _ignored _match _approximate _list _prefix

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors \
    'reply=( $(( ($#PREFIX+$#SUFFIX)/3 )) numeric )'
    
# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $fg_bold[white]'%U%d%b%u'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*:expand:*' tag-order all-expansions
zstyle ':completion:*' group-name ''

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Use 'ps -au$USER' for fetch user process list
zstyle ':completion:*:processes' command 'ps -aux' #u$USER'
zstyle ':completion:*:*:(kill|killall):*' menu yes select
zstyle ':completion:*:*:(kill|killall):*' force-list always

# files to ignore 
zstyle ':completion:*:(all-|)files' ignored-patterns '*.bk' '*.bak' '*.old' '*~' '.*.sw?'
zstyle ':completion:*:(all-|)files' ignored-patterns '(|*/)svn'
zstyle ':completion:*:cd:*' ignored-patterns '(*/)#svn'
zstyle ':completion:*:*:zless:*' file-patterns '*(-/):directories *.gz:all-files'
zstyle ':completion:*:*:lintian:*' file-patterns '*(-/):directories *.deb'
zstyle ':completion:*:*:less:*' ignored-patterns '*.gz'
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'

zstyle ':completion:*:functions' ignored-patterns '_*'

# http://xana.scru.org/2005/08/20#ignorelatexjunk
zstyle -e ':completion:*:*:vim#:*:*' ignored-patterns \
  'texfiles=$(echo ${PREFIX}*.tex); [[ -n "$texfiles" ]] &&
  reply=(*.(aux|dvi|log|ps|pdf|bbl|toc|lot|lof|latexmain)) || reply=()'


##########
# PROMPT #
##########
setopt prompt_subst
autoload -Uz vcs_info
# set some colors
for COLOR in RED GREEN YELLOW WHITE BLACK CYAN GREY BLUE; do
    eval PR_$COLOR='%{$fg_no_bold[${(L)COLOR}]%}'         
    eval PR_BRIGHT_$COLOR='%{$fg_bold[${(L)COLOR}]%}'
done                                                 
PR_RESET="${reset_color}"

typeset -A color_hosts
set -A color_hosts 'bob' $PR_GREEN 'billy' $PR_CYAN 'gizmo' $PR_YELLOW

# set formats
# %b - branchname
# %u - unstagedstr (see below)
# %c - stangedstr (see below)
# %a - action (e.g. rebase-i)
# %R - repository path
# %S - path in the repository

FMT_TYPE="${PR_WHITE}%s/"
FMT_BRANCH="${PR_GREEN}%b%u%c" # e.g. master¹²
FMT_ACTION="${PR_WHITE}/(${PR_CYAN}%a${PR_WHITE}%)"  # e.g. (rebase-i)

# check-for-changes can be really slow.
# you should disable it, if you work with large repositories    
zstyle ':vcs_info:*:prompt:*' check-for-changes true
zstyle ':vcs_info:*:prompt:*' unstagedstr '¹'  # display ¹ if there are unstaged changes
zstyle ':vcs_info:*:prompt:*' stagedstr '²'    # display ² if there are staged changes
zstyle ':vcs_info:*:prompt:*' actionformats " ${FMT_TYPE}${FMT_BRANCH}${FMT_ACTION}"
zstyle ':vcs_info:*:prompt:*' formats       " ${FMT_TYPE}${FMT_BRANCH}"

color_host_normal="$color_hosts[$(hostname -s)]"
color_host_normal="${color_host_normal:=$PR_BLUE}"
color_user_normal=$color_host_normal

function title {
	if [[ $TERM = screen* ]]; then 
		#In screen this is %w
		print -nR $'\033k'$1$'\033'\\ 
	fi 
	#In screen this is %h
    if [[ $TERM != linux ]]; then
    	print -nR $'\033]0;'$2$'\007'
    else
        print -nR $'\033]0;'$1' - '$2$'\007'
    fi
}

path_cut_offset=15
prompt_precmd () {
    local prompt_line_1a prompt_line_1b prompt_line_2 prompt_padding rprompt_line_2 color_user color_host
    color_user=$color_user_normal
    color_host=$color_host_normal
    [[ $USER = "root" ]] && color_user=$PR_BRIGHT_RED color_host=$PR_BRIGHT_RED

    local user="${color_user}$USER" 
    local host="${color_host}$(hostname)"
    local coma="${PR_BRIGHT_RED}:"
    local at="${PR_BRIGHT_RED}@"
    local rpath="${PR_BRIGHT_BLUE}%~"
    local opensep="${PR_BRIGHT_GREY}["
    local closesep="${PR_BRIGHT_GREY}]"
    local dollar="%(?,${PR_BRIGHT_GREEN},${PR_BRIGHT_RED})$"
    local return_code="${PR_BRIGHT_WHITE}?:%(?,${PR_BRIGHT_WHITE},${PR_BRIGHT_RED})%?"
    local njob="${PR_BRIGHT_WHITE}j:%j"

    prompt_line_1a="${opensep}${user}${at}${host}${coma} ${rpath}${closesep}"
    prompt_line_1b=""
    [ -n "$vcs_info_msg_0_" ] && vcs_info_msg="${vcs_info_msg_0_}" || vcs_info_msg=""
    prompt_line_2="${opensep}${njob} ${return_code}${vcs_info_msg}${closesep} ${dollar} ${PR_WHITE}"
    rprompt_line_2="${PR_WHITE}"

    local prompt_line_1a_width=${#${(S%%)prompt_line_1a//\%\{*\%\}}}
    local prompt_line_1b_width=${#${(S%%)prompt_line_1b//\%\{*\%\}}}
    local prompt_padding_size=$(( COLUMNS - prompt_line_1a_width - prompt_line_1b_width ))
    eval "prompt_padding=\${(l:${prompt_padding_size}::${prompt_gfx_hyphen}:)_empty_zz}"
    export PS1=$'\n'$prompt_line_1a$prompt_padding$prompt_line_1b$'\n'$prompt_line_2
    export RPS1=$rprompt_line_2

    local pwd=${PWD/$HOME/"~"}
    [ ${#pwd} -gt $path_cut_offset ] && pwd="..."$pwd[${#pwd}-$path_cut_offset,${#pwd}]
    win_title="["${PWD/$HOME/"~"}"]"
    title "$pwd" "$win_title"
}

prompt_preexec () {
        emulate -L zsh
        local -a cmd
        cmd=(${(z)1})
        if [ "$cmd[1]" = "fg" ]; then 
            cmd=($(jobs | grep -v "continued" | sed 's,.*suspended *,,g' | head -n1 ))
        fi
        arg=$cmd[2,-1]
        if [ ${#arg} -gt $path_cut_offset ]
        then
                arg=" ..."$arg[${#arg}-$path_cut_offset,${#arg}]
        else
                arg=" "$arg
        fi
        print -nR "${PR_RESET}"
        win_title="["$(pwd)"] "$cmd[1,-1]
        title "$cmd[1]$arg" "$win_title"
        if [ "$cmd[1]" = "scr" -o "$cmd[1]" = "sr" -o "$cmd[1]" = "sn" ]; then
            print -nR "${PR_RESET}"
            title "$cmd[1]$arg" "Other"
        fi
}

export SPROMPT="${PR_RESET}""zsh: corriger ${PR_BRIGHT_GREEN}"%R"${PR_RESET} en ${PR_BRIGHT_GREEN}"%r"${PR_RESET} ? (yNea)"

function vcsinfo_precmd { vcs_info 'prompt'; }
precmd_functions+=vcsinfo_precmd
precmd_functions+=prompt_precmd
preexec_functions+=prompt_preexec


mka () { time schedtool -B -n 1 -e ionice -n 1 make -j $(nproc) "$@" }
imka () { time schedtool -D -n 19 -e ionice -c 3 make -j $(nproc) "$@" }
masq (){ sudo iptables -t nat -A POSTROUTING -s "$1" ! -d "$1" -j MASQUERADE }
ban(){ sudo iptables -I INPUT 1 -s "$1" -j DROP }
unban(){ sudo iptables -D INPUT -s "$1" -j DROP }
alias idletask='schedtool -D -n 19 -e ionice -c 3'
alias batchtask='schedtool -B -n 1 -e ionice -n 1'

function cdt() { cd $(mktemp -td cdt.XXXXXXXX) ; pwd }
function s() { pwd >| /dev/shm/.saved_dir; }
function i() { p="$(cat /dev/shm/.saved_dir 2>/dev/null)"; [ -d $p ] && cd $p }
function p() { cd ~/workspace/os_dev/stack/*${1}*(/[0,1]) ; s }
i
postcmd_functions+=s
chpwd_functions+=s

inw(){ Xephyr :1 & pid=$! ; DISPLAY=:1 $*; kill $pid ;}

if [ "$HOST" = "bob" ]; then
    function novpn() { sudo systemctl stop openvpn@redhat; sudo /etc/init.d/fastd stop; sudo rm /etc/dnsmasq.d/redhat.conf;sudo /etc/init.d/dnsmasq restart; }
    function vpnrh() { sudo systemctl restart openvpn@redhat ;}
    alias vpnttnn='sudo /etc/init.d/fastd start'
else
    function novpn(){ local activevpn="$(nmcli -t -f TYPE,NAME c s --active | sed -ne 's/vpn:\(.*\)/\1/gp')" ; [ "$activevpn" ] && nmcli c d "$activevpn" && sudo systemctl restart dnsmasq ; }
    function vpnrh(){ nmcli c u "Redhat UDP" && sudo systemctl restart dnsmasq; }
fi

alias Q='exec zsh'
alias sc="screen -RDD"
alias open="xdg-open"
alias rm="nocorrect rm -i"
alias mv="nocorrect mv -i"
alias cp="nocorrect cp -i"
alias ln='nocorrect ln'
alias mkdir='nocorrect mkdir'
[ ${UID} -eq 0 ] && alias sudo="" || alias sudo="nocorrect sudo"
alias wget='noglob wget'
alias curl='noglob curl'
alias apt-cache='noglob apt-cache'
alias man="LANG=C man"
alias df="df -h"
alias diff='diff -rNu'
alias cmutt="find ~/.mutt/cache/headers/ -type f -exec tcbmgr optimize -nl {} \; ; mutt"
alias vi="vim"
alias svi="sudo -E vim" 
alias psql="sudo -i -u postgres psql"
alias pyclean='find . -type f -name "*.py[co]" -delete'
alias getaptkey='sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com'

function of() { lsof -np "$1" }
compdef _pids of

# FIND STUFF
alias locate='noglob locate'
alias find='noglob find'
alias qf='find . -iname '
alias findnosecure="find . -perm +4000 -print"
function sfind(){ find "$@" | egrep -v '(binaire|\.svn|\.git|\.bzr)' ; }

# GREP STUFF
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
function sgrep(){ grep "$@" --color=always| egrep -v '(binaire|\.svn|\.git)' ; } 
function g(){ grep --color=always "$@" | more }

# ZSH STUFF
alias zmv="nocorrect noglob zmv"
alias mmv="nocorrect noglob zmv -W"
alias zcp='zmv -C'
alias zln='zmv -L'

hash -d doc=/usr/share/doc
hash -d log=/var/log

# LS stuff
# Remove bold for image/audio/video and archive, generated with :
#  dircolors | sed 's/\(\*\.[^=]*=\)01/\100/g'
LS_COLORS='rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32:*.tar=00;31:*.tgz=00;31:*.arc=00;31:*.arj=00;31:*.taz=00;31:*.lha=00;31:*.lz4=00;31:*.lzh=00;31:*.lzma=00;31:*.tlz=00;31:*.txz=00;31:*.tzo=00;31:*.t7z=00;31:*.zip=00;31:*.z=00;31:*.Z=00;31:*.dz=00;31:*.gz=00;31:*.lrz=00;31:*.lz=00;31:*.lzo=00;31:*.xz=00;31:*.bz2=00;31:*.bz=00;31:*.tbz=00;31:*.tbz2=00;31:*.tz=00;31:*.deb=00;31:*.rpm=00;31:*.jar=00;31:*.war=00;31:*.ear=00;31:*.sar=00;31:*.rar=00;31:*.alz=00;31:*.ace=00;31:*.zoo=00;31:*.cpio=00;31:*.7z=00;31:*.rz=00;31:*.cab=00;31:*.jpg=00;35:*.jpeg=00;35:*.gif=00;35:*.bmp=00;35:*.pbm=00;35:*.pgm=00;35:*.ppm=00;35:*.tga=00;35:*.xbm=00;35:*.xpm=00;35:*.tif=00;35:*.tiff=00;35:*.png=00;35:*.svg=00;35:*.svgz=00;35:*.mng=00;35:*.pcx=00;35:*.mov=00;35:*.mpg=00;35:*.mpeg=00;35:*.m2v=00;35:*.mkv=00;35:*.webm=00;35:*.ogm=00;35:*.mp4=00;35:*.m4v=00;35:*.mp4v=00;35:*.vob=00;35:*.qt=00;35:*.nuv=00;35:*.wmv=00;35:*.asf=00;35:*.rm=00;35:*.rmvb=00;35:*.flc=00;35:*.avi=00;35:*.fli=00;35:*.flv=00;35:*.gl=00;35:*.dl=00;35:*.xcf=00;35:*.xwd=00;35:*.yuv=00;35:*.cgm=00;35:*.emf=00;35:*.axv=00;35:*.anx=00;35:*.ogv=00;35:*.ogx=00;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.m4a=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:*.axa=00;36:*.oga=00;36:*.spx=00;36:*.xspf=00;36:';
export LS_COLORS
alias ls="LC_COLLATE=POSIX ls -h --color=auto -bCF --color=auto --group-directories-first"
alias ll="ls -lF"
alias la="ls -aF"
alias lla="ls -alF"
alias lsd='ls -ld *(-/DN)'
alias lsdir="for dir in *;do;if [ -d \$dir ];then;du -xhsL \$dir 2>/dev/null;fi;done"
function l(){ ls -hla --color="always" "$@" | more }
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
unset _LS_OPTS

# handy documentation lookup on Debian
# from http://www.michael-prokop.at/computer/config/.zshrc
doc() { cd /usr/share/doc/$1 && ls } 
_doc() { _files -W /usr/share/doc -/ }
compdef _doc doc

function killd(){ DISPLAY="" ps xae | grep DISPLAY=:$1 | grep -v grep | awk '{print $1}' | zargs -r kill -9 }

function fwget(){
    local filename=$(wget -S --spider "$*" 2>&1| grep 'Content-disposition: attachment' | sed -e '/Content-disposition: attachment/s/.*filename="\(.*\)"/\1/g')
    if [ -n "$filename" ] ; then
       wget -O $filename "$*"
    else
       echo " * No attachement found"
    fi
}

# Service stuff
alias service="nocorrect sudo service"
alias systemctl="nocorrect sudo systemctl"
compdef _service invoke-rc.d

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

sshclean(){
    hostname=$(echo $1 | sed 's/\.t$/.tetenauetral.net/g')
    for i in $hostname $(dig +short $hostname A; dig +short $hostname AAAA); do 
        ssh-keygen -R "[$i]:2222"
    done
}

update-flash() {
    sudo update-pepperflashplugin-nonfree --status
    sudo update-pepperflashplugin-nonfree --install
    sudo update-pepperflashplugin-nonfree --status
}

etox() {
    zparseopts -D e+:=env
    typeset -A helper
    helper=($(seq 1 ${#env}))
    rootdir="."
    [ ! -d "$rootdir/.tox" ] && rootdir=".."
    [ ! -d "$rootdir/.tox" ] && rootdir="../.."
    [ ! -d "$rootdir/.tox" ] && rootdir="../../.."
    [ ! -d "$rootdir/.tox" ] && rootdir="../../../.."
    for item in ${(@v)helper}; do
        for e in "${(@s/,/)env[$item]}" ; do
            $rootdir/.tox/$e/bin/"$@"
        done
    done
}

utox() {
    find /workspace/pip_cache/ -name '*.dev*' -delete
    zparseopts -D e+:=env
    typeset -A helper
    helper=($(seq 1 ${#env}))
    for item in ${(@v)helper}; do
        for e in "${(@s/,/)env[$item]}" ; do
            etox -e $e "$@" pip install -U pip
            etox -e $e "$@" pip install -U -e . $(tox --notest --showconfig | awk '/^\[testenv:'$e'\]$/{while ($1 != "deps") { getline ; }; print $0 ; }' | sed -e 's/\s*deps\s*=\s*\[\(.*\)\]/\1/g' | sed -e 's/, / /g')
        done
    done
}

mtox(){
    targets=($({ echo -e 'py27\npy34' ; sed -n '/testenv/s/\[testenv:\(.*\)\]/\1/gp' tox.ini }| sort -u))
    PS3='Please enter your choice: '
    select opt in "${targets[@]}"; do
        LATEST_TOX_CMD=("-e$opt" "$@")
        tox -e$opt "$@"
        break
    done
}
ltox(){
    tox $LATEST_TOX_CMD
}

alias etox="nocorrect etox"
alias utox="nocorrect utox"
#alias tox="rm .ropeproject -rf; tox"



# vim:ft=zsh
