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

log(){
    echo "### $@ ###"
}

typeset -a flist="zshrc zprofile zlogin zlogout zshenv wgetrc
mutt gitconfig gitignore-global ctags i3 config/dunst tmux
tmux.conf xsessionrc urlview gnupg/gpg.conf gnupg/gpg-agent.conf config/nvim"

typeset -a rlist="config/awesome screenrc config/khard vdirsyncer conkyrc"


setup_repo(){
    log "Sync repos"
    #if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
    #    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    #    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    #    apt update -y
    #fi
}
ensure_yum() {
    [ -x "$(which yum)" ] || return
    for name in "$@"; do
         rpm -q $name > /dev/null || sudo yum install -y ${name}
    done
}

ensure_apt() {
    [ -x "$(which apt)" ] || return
    for name in "$@"; do
        if [ "${name:0:1}" == "-" ]; then
            name=${name:1}
            [ -f /var/lib/dpkg/info/${name}.list -o -f /var/lib/dpkg/info/${name}:amd64.list ] && sudo apt -y purge ${name}
        else
            [ ! -f /var/lib/dpkg/info/${name}.list -a ! -f /var/lib/dpkg/info/${name}:amd64.list ] && sudo apt -y install ${name}
        fi
    done
}

setup_env_link() {
    log "Setup links"
    haserror=
    error(){
        log "file $1 already exist (.$1 = $(readlink -f .$1))"
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
        log "file $1 is not a link"
    }
    pushd $HOME > /dev/null
    for f in $flist; do
        [ -L ".$f" ] && rm -f $f || error $f
    done
    rm -rf ~/.vim
    popd > /dev/null
}

setup_vim(){
    log "Setup vim"
    ensure_apt -yarnpkg -neovim -python-neovim -python3-neovim # nodejs yarn
    rm -rf ~/.vim ~/.vimrc*
    dest="${HOME}/.bin/nvim"
    if [[ ! -e "${dest}" || "$(find $dest -mtime +30)" ]]; then
        curl -fLo $dest --create-dirs \
	    https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
        chmod +x ~/.bin/nvim
    fi
    dest="${HOME}/.local/share/nvim/site/autoload/plug.vim"
    if [[ ! -e "${dest}" || "$(find $dest -mtime +30)" ]]; then
        curl -fLo $dest --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
    ~/.bin/nvim "+set nomore" +PlugInstall! +PlugClean! +PlugUpdate! +qall
    # nvim "+set nomore" "+CocInstall coc-python coc-json coc-emoji coc-word coc-css coc-gocode coc-html coc-yaml"
}

setup_fonts(){
    log "Setup fonts"
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
    log "Sync git repositories"
    git pull --rebase --recurse-submodules
    git submodule init
    git submodule update
    export BOOSTRAP_UPDATED=1
    exec $0 $INITIAL_OPTS
}

setup_st(){
    log "Setup st"
    ensure_apt libxft-dev libxext-dev libfontconfig1-dev libxrender-dev libx11-dev
    ensure_yum libXft-devel libXet-devel bfontconfig1-devel libXrender-devel libX11-devel
    (cd st && make clean && make && tic -sx st.info)
}

setup_python(){
    log "Setup python stuffs"
    ensure_apt libiw-dev  # i3pystatus
    ensure_yum libiw-devel  # i3pystatus
    ensure_apt python3-pip python-pip virtualenvwrapper libasound2-dev

    python3 -m pip install --quiet --user --upgrade --upgrade-strategy eager -r ~/.env/requirements-py3.txt
    python2 -m pip install --quiet --user --upgrade --upgrade-strategy eager -r ~/.env/requirements-py2.txt
}

disable_gpg_crap(){
    log "Setup gpg"
    # debian strech now starts agents with systemd. That can be fancy, but this break gpg-agent forwarding
    for action in stop disable mask; do
        systemctl --user $action gpg-agent.socket gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket dirmngr.socket gpg-agent.service
    done
}

maybe_do_update
cleanup_old_link
[ "$force" ] &&  cleanup_forced
setup_repo
setup_env_link
setup_python
setup_vim
setup_st
case $HOSTNAME in
    bob|billy|trudy) ;;
    *) disable_gpg_crap
esac
if [ "$DISPLAY" == ":0" ]; then
    setup_fonts
fi
