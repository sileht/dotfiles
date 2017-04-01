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
tmux.conf config/khard vdirsyncer xsessionrc urlview conkyrc"

typeset -a rlist="spf13-vim spf13-vim-3 vimrc.before vimrc.bundles
vimrc.bundles.fork vimrc.fork notmuch-config vimrc.old vimrc.ori specemacs.d
emacs.d vimrc.before.local vimrc.bundles.local vimrc.local zsh lbdbrc
pythonrc.py spacemacs Xresources"

ensure_pkgs() {
    for name in "$@"; do
        if [ -x $(which apt) ]; then
            [ ! -f /var/lib/dpkg/info/${name}.list -a ! -f /var/lib/dpkg/info/${name}:amd64.list ] && sudo apt -y install ${name}
        fi
    done
}

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
    if [ ! -e ~/.vim/autoload/plug.vim -o -d "~/.vim/bundle/" ]; then
        rm -rf ~/.vim ~/.vimrc*
        ln -sf ~/.env/vimrc ~/.vimrc
        mkdir ~/.vim
        ln -sf ~/.vimrc ~/.vim/init.vim
        ln -sf ~/.vim ~/.config/nvim
        ln -sf ~/.vim ~/.local/share/nvim
    fi
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    if [ -x "$(which nvim)" ]; then
        nvim "+set nomore" +PlugInstall! +PlugClean! +PlugUpdate! +qall
    else
        vim "+set nomore" +PlugInstall! +PlugClean! +PlugUpdate! +qall
    fi
}
setup_i3pystatus(){
    ~/.i3/update.sh
}

setup_fonts(){
    update_fc=
    fontdir="/home/sileht/.local/share/fonts"
    mkdir -p $fontdir
    name="UbuntuMonoNerdFonts.ttf"
    dest="${fontdir}/${name}"
    if [[ ! -e "${dest}" || "$(find $dest -mtime +30)" ]]; then
        curl -q "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20derivative%20Powerline%20Nerd%20Font%20Complete.ttf" -o "${dest}"
        update_fc=1
    fi

    name="iosevka-pack-1.12.0.zip"
    dest="${fontdir}/${name}"
    if [[ ! -e "${dest}" || "$(find $dest -mtime +30)" ]]; then
        curl -q https://github.com/be5invis/Iosevka/releases/download/v1.12.0/$name -L -o "${dest}"
        update_fc=1
        ( cd $fontdir && unzip ${name} )
    fi
    [ "$update_fc" ] && fc-cache -fv
}

maybe_do_update(){
    [ "$BOOSTRAP_UPDATED" ] && return
    git pull --rebase --recurse-submodules
    git submodule init
    git submodule update
    export BOOSTRAP_UPDATED=1
    exec $0 $INITIAL_OPTS
}

setup_st(){
    ensure_pkgs libxft-dev libxext-dev libfontconfig1-dev libxrender-dev libx11-dev
    (cd st && make && tic -sx st.info)
}

maybe_do_update
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_env_link
setup_vim
setup_st
if [ "$DISPLAY" == ":0" ]; then
    setup_fonts
    setup_i3pystatus
fi
