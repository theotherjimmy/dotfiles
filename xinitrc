#!/usr/bin/bash
alacritty &
if [ -r $HOME/Pictures/$(hostname).png ] ; then
  feh --bg-max $HOME/Pictures/$(hostname).png
else
  feh --bg-max $HOME/Pictures/bg.png
fi
export MOZ_USE_XINPUT2=true
setxkbmap us -variant dvp -option caps:escape
exec runsvdir ${HOME}/.local/service
