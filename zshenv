[[ ! -o rcs ]] && return

fpath=($fpath ~/.env/zsh-completions/src ~/.env/zsh-completions-mine)

export ZVARDIR=$HOME/.var/zsh
export TMPDIR=/tmp

[ ! -d $ZVARDIR ] && mkdir -p $ZVARDIR
# Source PATH
source ~/.xsessionrc

export DEBEMAIL=sileht@sileht.net
export DEBFULLNAME='Mehdi Abaakouk'
export EMAIL_ADDR=enjoy.zsh@foo.bar
#export DEBUILD_DPKG_BUILDPACKAGE_OPTS="-i -ICVS -I.svn -k 'Mehdi Abaakouk <sileht@sileht.net>'"
#export DEB_SIGN_KEYID="A351 AB80 5797 B657 D490  BAD7 1892 B42F CEAA EBC8"
#export DEBUILD_SIGNING_USERNAME=sileht
export QUILT_PATCHES=debian/patches
export QUILT_DIFF_ARGS="--no-timestamps --no-index -pab"
export QUILT_REFRESH_ARGS="--no-timestamps --no-index -pab"
export QUILT_PATCH_OPTS="--reject-format=unified"

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
# vim:ft=zsh
