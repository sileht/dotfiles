[[ ! -o rcs ]] && return

export ZVARDIR=$HOME/.var/zsh
export TMPDIR=/tmp

[ ! -d $ZVARDIR ] && mkdir -p $ZVARDIR
# Source PATH
source ~/.xsessionrc
[ -f "~/.secrets" ] && source ~/.secrets

export EDITOR=nvim
export VISUAL=nvim

KEYTIMEOUT=1

# Less config
export LESS='--quit-if-one-screen --no-init --hilite-search --jump-target=0.5 --SILENT --raw-control-chars'
export LESSHISTFILE=~/.var/less/history
[[ -d ${LESSHISTFILE%/*} ]] || mkdir --parent ${LESSHISTFILE%/*}
export PAGER=less
export LESSCOLOR=always
export LESSCOLORIZER="highlight -O ansi"
export LESSOPEN="|lesspipe %s"

export MOSH_PREDICTION_DISPLAY=always

export GEM_HOME=$HOME/.ruby-gems

export DOCKER_BUILDKIT=1

# vim:ft=zsh
