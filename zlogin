if [ -x "$(which gpgconf)" ]; then
    gpg_run_path=$(gpgconf --list-dirs socketdir)
    if [ ! -e "$gpg_run_path/S.gpg-agent" ] ; then
        gpgconf --create-socketdir
        for f in S.gpg-agent S.gpg-agent.ssh; do
            ln -s ${HOME}/.var/$f $gpg_run_path/$f
        done
    fi
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
fi
