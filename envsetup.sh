#!/bin/bash

cd $HOME

typeset -a flist="zsh vimrc.local vimrc.bundles.local screenrc zshenv wgetrc pythonrc.py mutt config/awesome" 

setup_env_link()
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

setup_power_line_fonts(){
    mkdir -p ~/.fonts/ ~/.config/fontconfig/conf.d/
    rm -f ~/.fonts/PowerlineSymbols.otf ~/.config/fontconfig/conf.d/10-powerline-symbols.conf
    wget -O ~/.fonts/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    wget -O ~/.config/fontconfig/conf.d/10-powerline-symbols.conf https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
    fc-cache -vf ~/.fonts

}

setup_env_link
setup_power_line_fonts
