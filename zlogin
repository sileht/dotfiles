case $HOSTNAME in
    bob|gizmo);;
    *)
        gpgconf --create-socketdir
        ln -s ${HOME}/.var/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent
        ln -s ${HOME}/.var/S.gpg-agent.ssh /run/user/1000/gnupg/S.gpg-agent.ssh
        ;;
esac
