case $HOSTNAME in
    bob|gizmo);;
    *)
        gpgconf --create-socketdir
        ln -s ${HOME}/.var/S.gpg-agent /run/user/1000/gnupg/S.gpg-agent
        ;;
esac
