[[ ! -o rcs ]] && return

fpath=($fpath ~/.env/zsh-completions/src)

export ZVARDIR=$HOME/.var/zsh
export TMPDIR=/tmp

[ ! -d $ZVARDIR ] && mkdir -p $ZVARDIR
# Source PATH
source ~/.xsessionrc

export DEBEMAIL=sileht@sileht.net
export DEBFULLNAME='Mehdi Abaakouk'
export EMAIL_ADDR=enjoy.zsh@foo.bar
#export DEBUILD_DPKG_BUILDPACKAGE_OPTS="-i -ICVS -I.svn -k 'Mehdi Abaakouk <sileht@sileht.net>'"
export DEBUILD_SIGNING_USERNAME=sileht
export DEB_SIGN_KEYID=CEAAEBC8
export QUILT_PATCHES=debian/patches
export QUILT_DIFF_ARGS="--no-timestamps --no-index -pab"
export QUILT_REFRESH_ARGS="--no-timestamps --no-index -pab"
export QUILT_PATCH_OPTS="--reject-format=unified"

export EDITOR=vim
export VISUAL=vim
[ "$TTY" ] && export GPG_TTY=$TTY

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
export VAGRANT_DEFAULT_PROVIDER=lxc

export GEM_HOME=$HOME/.ruby-gems

export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
# vim:ft=zsh
