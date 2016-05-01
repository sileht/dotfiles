[[ ! -o rcs ]] && return

# disable core files
ulimit -c 0

#if [ -n "$ZDOTDIR" ] && [ -d "$ZDOTDIR" ]; then
#  rm -f $ZDOTDIR/**/*.zwc(D.N)
#  rm -f $ZDOTDIR/**/*.zwc.old(D.N)
#  for f ($ZDOTDIR/*(D.,@) $ZDOTDIR/**/*(.)) \
#    [[ $f:t != .gitignore ]] && zcompile $f
#fi

#if [ -n "$ZVARDIR" ] && [ -d "$ZVARDIR" ]; then
#  rm -f $ZVARDIR/**/*.zwc(.N)
#  rm -f $ZVARDIR/**/*.zwc.old(.N)
#  for f ($ZVARDIR/comp*(.N)) zcompile $f
#fi

# vim:ft=zsh
