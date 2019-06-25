#!/usr/bin/bash
alacritty &
xev &
feh --bg-max Pictures/bg.png
$HOME/src/archlinux/cnx/target/release/cnx &
mv $HOME/.local/session.log $HOME/.local/session.log.last

exec $HOME/.cargo/bin/watchexec -w $HOME/src/archlinux/lanta/target/release/lanta -r -- $HOME/src/archlinux/lanta/target/release/lanta  > $HOME/.local/session.log
