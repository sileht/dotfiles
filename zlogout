[[ ! -o rcs ]] && return

sudo -K 2>/dev/null || :
clear
[ -x "$(which clear_console 2>/dev/null)" ] && clear_console -q

# vim:ft=zsh
