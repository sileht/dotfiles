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


typeset -a flist="zsh vimrc screenrc zshenv wgetrc pythonrc.py mutt config/awesome gitconfig lbdbrc gitignore-global ctags i3 config/dunst"
typeset -a rlist=""

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
    dpkg -l | grep -q fonts-powerline || sudo apt-get install fonts-powerline
}

setup_vim(){
    if [ ! -e ~/.vim/autoload/plug.vim ] ; then
	if [ -d "~/.vim/bundle/" ]; then
		rm -rf ~/.vim ~/.vimrc*
                ln -sf ~/.env/vimrc .vimrc
	fi
 	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    vim "+set nomore" +PlugUpgrade! +PlugInstall! +PlugClean! +PlugUpdate! +qall
}

do_update(){
    git pull --rebase
    exec $0 $COPY_OPTS -e
}

[ "$update" ] && do_update 
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_env_link
if [ ! "$light" ]; then 
    setup_power_line
    setup_vim
fi
