case $HOSTNAME in
    bob|gizmo);;
    *)
        gpgconf --create-socketdir
        for f in /S.gpg-agent S.gpg-agent.ssh; do
            dest="/run/user/1000/gnupg/$f"
            [ ! -e "$dest" ] && ln -s ${HOME}/.var/$f /run/user/1000/gnupg/$f
        done
        ;;
esac
