#!/bin/bash

cd $HOME

typeset -a flist="zsh vimrc.local vimrc.bundles.local screenrc zshenv wgetrc pythonrc.py mutt config/awesome" 

haserror=
error(){
	echo "* file $f already exist (.$f = $(readlink -f .$f))"
	haserror=1
}

for f in $flist; do 
	[ -e ".$f" -a "$(readlink -f .$f)" != "$HOME/.env/$f" ] && error $f
done

[ -n "$haserror" ] && exit 1

for f in $flist; do 
	if [ ! -e ".$f" ] ; then
		ln -sf ~/.env/$f .$f
	fi
done
