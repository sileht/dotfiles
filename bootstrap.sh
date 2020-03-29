#!/bin/bash

setup_xorg(){
    log "Setup i3pystatus"
    python3 -m pip install --quiet --user --upgrade --upgrade-strategy eager -r ~/.env/requirements-py3-i3pystatus.txt
}
setup_python(){
    log "Setup python stuffs"
    ensure_apt libiw-dev  # i3pystatus
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

setup_python
case $HOSTNAME in
    bob|trudy|billy) setup_xorg ;;
    *) disable_gpg_crap ;;
esac
