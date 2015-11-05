urxvtd &
emacs -f start-server &
unclutter -idle 1 -root &
start-pulseaudio-x11 &
redshift &
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources
[[ -f /etc/X11/xinit/xinitrc.d/30-dbus.sh ]] && source /etc/X11/xinit/xinitrc.d/30-dbus.sh
exec xmonad
