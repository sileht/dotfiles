#!/bin/bash

here=$(dirname $(readlink -f $0))

INITIAL_OPTS="$@"
OPTS=$(getopt -o fu -- "$@")
eval set -- "$OPTS"

while true ; do
    case "$1" in
        -f) force=1 ;;
        -u) BOOSTRAP_UPDATED=1 ;;
        --) shift; break;;
    esac
    shift
done

typeset -a flist="zshrc zprofile zlogin zlogout zshenv vimrc screenrc wgetrc
mutt config/awesome gitconfig gitignore-global ctags i3 config/dunst tmux vim/coc-settings.json
tmux.conf config/khard vdirsyncer xsessionrc urlview conkyrc gnupg/gpg.conf gnupg/gpg-agent.conf"

typeset -a rlist="spf13-vim spf13-vim-3 vimrc.before vimrc.bundles
vimrc.bundles.fork vimrc.fork notmuch-config vimrc.old vimrc.ori specemacs.d
emacs.d vimrc.before.local vimrc.bundles.local vimrc.local zsh lbdbrc
pythonrc.py spacemacs Xresources"

ensure_yum() {
    [ -x "$(which yum)" ] || return
    for name in "$@"; do
         rpm -q $name > /dev/null || sudo yum install -y ${name}
    done
}

ensure_apt() {
    [ -x "$(which apt)" ] || return
    for name in "$@"; do
        [ ! -f /var/lib/dpkg/info/${name}.list -a ! -f /var/lib/dpkg/info/${name}:amd64.list ] && sudo apt -y install ${name}
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
    #ensure_apt nodejs yarnpkg yarn
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
    return

    dest=$(python3 -c 'import sys; print("'$HOME'/.local/lib/python" + ".".join(map(str, sys.version_info[0:2])) + "/site-packages")')
    fix="$HOME/.env/i3/apiclient-fix.patch"
    patch --dry-run -p1 -R -d $dest -i $fix >/dev/null 2>&1 || patch -p1 -d $dest -i $fix
}

setup_fonts(){
    update_fc=
    fontdir="/home/sileht/.local/share/fonts"
    mkdir -p $fontdir
    name="UbuntuMonoNerdFonts.ttf"
    url="https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete.ttf?raw=true"
    dest="${fontdir}/${name}"
    if [[ ! -e "${dest}" || "$(find $dest -mtime +30)" ]]; then
        curl -L -q "$url" -o "${dest}"
        update_fc=1
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
    ensure_apt libxft-dev libxext-dev libfontconfig1-dev libxrender-dev libx11-dev
    ensure_yum libXft-devel libXet-devel bfontconfig1-devel libXrender-devel libX11-devel
    (cd st && make clean && make && tic -sx st.info)
}

setup_python(){
    ensure_apt libiw-dev  # i3pystatus
    ensure_yum libiw-devel  # i3pystatus
    python3 -m pip install --user --upgrade --upgrade-strategy eager -r ~/.env/requirements.txt
}

disable_gpg_crap(){
    # debian strech now starts agents with systemd. That can be fancy, but this break gpg-agent forwarding
    for action in stop disable mask; do
        systemctl --user $action gpg-agent.socket gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket dirmngr.socket gpg-agent.service
    done
}

maybe_do_update
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_env_link
setup_vim
setup_st
setup_python
case $HOSTNAME in
    bob|billy) ;;
    *) disable_gpg_crap
esac
if [ "$DISPLAY" == ":0" ]; then
    setup_fonts
    setup_i3pystatus
fi
