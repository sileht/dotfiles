#!/bin/bash


here=$(dirname $(readlink -f $0))

if [ "$1" == "-l" ] ; then
    light=1
fi
cd $HOME

typeset -a flist="zsh vimrc.local vimrc.bundles.local screenrc zshenv wgetrc pythonrc.py mutt config/awesome gitconfig spf13-vim-3 lbdbrc"

setup_submodule() {
	cd $here
	git submodule update --init spf13-vim-3
        cd -
}

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
    curl -L -q -# -o ~/.fonts/PowerlineSymbols.otf https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
    curl -L -q -# -o ~/.config/fontconfig/conf.d/10-powerline-symbols.conf https://raw.github.com/Lokaltog/powerline/develop/font/10-powerline-symbols.conf
    rm -rf ~/.fonts.conf.d
    [ -x "$(which fc-cache)" ] && fc-cache -vf ~/.fonts
}

setup_spf13(){
    if [ ! -d ~/.vim ] ; then
        TERM=xterm-256color ~/.spf13-vim-3/bootstrap.sh
    else
        vim +BundleInstall! +BundleClean! +qall
    fi
}

setup_submodule
setup_env_link
if [ -z "$light" ]; then 
    setup_power_line
    setup_spf13
fi
