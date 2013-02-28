#!/bin/bash


here=$(dirname $(readlink -f $0))
cd $HOME

typeset -a flist="zsh vimrc.local vimrc.bundles.local screenrc zshenv wgetrc pythonrc.py mutt config/awesome gitconfig" 

setup_env_link() {
    haserror=
    error(){
        echo "* file $f already exist (.$f = $(readlink -f .$f))"
        haserror=1
    }
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
}

setup_power_line(){
    mkdir -p ~/.fonts ~/.config/fontconfig/conf.d
    rm -f ~/.fonts/PowerlineSymbols.otf ~/.config/fontconfig/conf.d/10-powerline-symbols.conf
    wget -O ~/.fonts/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    wget -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    fc-cache -vf ~/.fonts
}

setup_spf13(){
    if [ ! -d ~/.spf13-vim-3 ] ; then
        # more quick than git clone
        tar -xzf $here/vim-spl-snapshot.tar.gz -C ~/
    fi
    TERM=xterm-256color ~/.spf13-vim-3/bootstrap.sh
}

setup_env_link
setup_power_line
setup_spf13
