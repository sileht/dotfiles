#!/bin/bash


here=$(dirname $(readlink -f $0))

COPY_OPTS="$@"
OPTS=$(getopt -o feul -- "$@")
eval set -- "$OPTS"

while true ; do
    case "$1" in
        -e) reexec=1 ;;
        -f) force=1 ;;
        -u) update=1 ;;
        -l) light=1 ;;
        --) shift; break;;
    esac
    shift
done
[ "$reexec" ] && update=


typeset -a flist="zsh vimrc.local vimrc.before.local screenrc zshenv wgetrc pythonrc.py mutt config/awesome gitconfig spf13-vim-3 lbdbrc gitignore-global ctags"
typeset -a rlist="vimrc.before vimrc.bunbles.local"

setup_submodule() {
	git submodule update --init spf13-vim-3
}

setup_env_link() {
    haserror=
    error(){
        echo "* file $1 already exist (.$1 = $(readlink -f .$1))"
        haserror=1
    }
    cd $HOME
    for f in $flist; do 
        [ -e ".$f" -a "$(readlink -f .$f)" != "$(readlink -f $HOME/.env/$f)" ] && error $f
    done
    [ -n "$haserror" ] && exit 1

    for f in $flist; do 
        if [ ! -e ".$f" ] ; then
            mkdir -p $(dirname .$f)
            ln -sf ~/.env/$f .$f
        fi
    done
    cd $here
}

cleanup_old_link(){
    haserror=
    error(){
        echo "* file $1 is not a link"
        haserror=1
    }
    cd $HOME
    for f in $rlist; do
        [ ! -e $f ] && continue
        [ -L ".$f" ] && rm -f $f || error $f
    done
    cd $here
}

cleanup_forced(){
    haserror=
    error(){
        echo "* file $1 is not a link"
        haserror=1
    }
    cd $HOME
    for f in $flist; do
        [ ! -e $f ] && continue
        [ -L ".$f" ] && rm -f $f || error $f
    done
    rm -rf ~/.vim
    cd $home
}

setup_power_line(){
    mkdir -p ~/.fonts ~/.config/fontconfig/conf.d
    rm -f ~/.fonts/PowerlineSymbols.otf ~/.config/fontconfig/conf.d/10-powerline-symbols.conf
    curl -L -q -# -o ~/.fonts/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    curl -L -q -# -o ~/.config/fontconfig/conf.d/10-powerline-symbols.conf https://raw.github.com/Lokaltog/powerline/develop/font/10-powerline-symbols.conf
    rm -rf ~/.fonts.conf.d
    [ -x "$(which fc-cache)" ] && fc-cache -vf ~/.fonts
}

setup_spf13(){
    if [ ! -d ~/.vim ] ; then
        
        TERM=xterm-256color sed -e '/BundleInstall/s/\.bundles//' ~/.spf13-vim-3/bootstrap.sh | bash
    else
        vim "+set nomore" +BundleInstall! +BundleClean +qall
    fi
}

do_update(){
    git pull --rebase
    exec $0 $COPY_OPTS -e
}

[ "$update" ] && do_update 
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_submodule
setup_env_link
if [ ! "$light" ]; then 
    setup_power_line
    setup_spf13
fi
