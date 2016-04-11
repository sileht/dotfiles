#!/bin/bash

here=$(dirname $(readlink -f $0))

INITIAL_OPTS="$@"
OPTS=$(getopt -o feul -- "$@")
eval set -- "$OPTS"

while true ; do
    case "$1" in
        -f) force=1 ;;
        -U) BOOSTRAP_UPDATED=1 ;;
        --) shift; break;;
    esac
    shift
done


typeset -a flist="zsh vimrc screenrc zshenv wgetrc pythonrc.py mutt
config/awesome gitconfig lbdbrc gitignore-global ctags i3 config/dunst"

typeset -a rlist="spf13-vim spf13-vim-3 vimrc.before vimrc.bundles
vimrc.bundles.fork vimrc.fork notmuch-config vimrc.old vimrc.ori
vimrc.before.local vimrc.bundles.local vimrc.local"


setup_env_link() {
    haserror=
    error(){
        echo "* file $1 already exist (.$1 = $(readlink -f .$1))"
        haserror=1
    }
    pushd $HOME > /dev/null
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
    popd > /dev/null
}

cleanup_old_link(){
    pushd $HOME > /dev/null
    for f in $rlist; do
        [ -L ".$f" ] && rm -f .$f
    done
    popd > /dev/null
}

cleanup_forced(){
    error(){
        echo "* file $1 is not a link"
    }
    pushd $HOME > /dev/null
    for f in $flist; do
        [ -L ".$f" ] && rm -f $f || error $f
    done
    rm -rf ~/.vim
    popd > /dev/null
}

setup_power_line(){
    dpkg -l | grep -q fonts-powerline || sudo apt-get install fonts-powerline
}

setup_vim(){
    if [ ! -e ~/.vim/autoload/plug.vim -a  -d "~/.vim/bundle/" ]; then
        rm -rf ~/.vim ~/.vimrc*
        ln -sf ~/.env/vimrc .vimrc
    fi
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim "+set nomore" +PlugInstall! +PlugClean! +PlugUpdate! +qall
}

maybe_do_update(){
    [ "$BOOSTRAP_UPDATED" ] && return
    git pull --rebase --recurse-submodules
    export BOOSTRAP_UPDATED=1
    exec $0 $INITIAL_OPTS
}

maybe_do_update 
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_env_link
setup_power_line
setup_vim
