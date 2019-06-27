#!/usr/bin/bash
alacritty &
xev &
feh --bg-max Pictures/bg.png
exec runsvdir ${HOME}/.local/service
