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


typeset -a flist="zshrc zprofile zlogin zlogout zshenv vimrc screenrc wgetrc
mutt config/awesome gitconfig gitignore-global ctags i3 config/dunst tmux
tmux.conf config/khard vdirsyncer"

typeset -a rlist="spf13-vim spf13-vim-3 vimrc.before vimrc.bundles
vimrc.bundles.fork vimrc.fork notmuch-config vimrc.old vimrc.ori specemacs.d
emacs.d vimrc.before.local vimrc.bundles.local vimrc.local zsh lbdbrc
pythonrc.py spacemacs Xresources"


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

setup_vim(){
    if [ ! -e ~/.vim/autoload/plug.vim -a  -d "~/.vim/bundle/" ]; then
        rm -rf ~/.vim ~/.vimrc*
        ln -sf ~/.env/vimrc .vimrc
    fi
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    vim "+set nomore" +PlugInstall! +PlugClean! +PlugUpdate! +qall
}
setup_i3pystatus(){
    ~/.i3/update.sh
}

setup_fonts(){
    mkdir -p ~/.local/share/fonts
    name="UbuntuMonoNerdFonts.ttf"
    dest="/home/sileht/.local/share/fonts/${name}"
    if [[ ! -e "${dest}" || "$(find $dest -mtime +30)" ]]; then
        curl -q "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20derivative%20Powerline%20Nerd%20Font%20Complete.ttf" -o "${dest}"
        fc-cache -fv
    fi
}

maybe_do_update(){
    [ "$BOOSTRAP_UPDATED" ] && return
    git pull --rebase --recurse-submodules
    git submodule init
    git submodule update
    export BOOSTRAP_UPDATED=1
    exec $0 $INITIAL_OPTS
}

maybe_do_update
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_env_link
setup_vim
if [ "$DISPLAY" == ":0" ]; then
    setup_fonts
    setup_i3pystatus
fi
