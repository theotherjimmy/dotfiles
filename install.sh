#!/usr/bin/bash
BASEDIR=$(dirname $0)
cd ${BASEDIR}

ln -sf ${PWD}/xinitrc ${HOME}/.xinitrc

for profile in $(echo ${HOME}/.mozilla/firefox/*.default) ; do
  mkdir -p ${profile}/chrome
  ln -sf ${PWD}/userChrome.css ${profile}/chrome/userChrome.css
done

mkdir -p ${HOME}/.config

XDG_DIRECTORIES="\
  alacritty\
  fish\
  dunst\
  polybar\
  "

for dir in $XDG_DIRECTORIES ; do
  if [ -d ${HOME}/.config/${dir} ] ; then
    mv ${HOME}/.config/${dir} ${HOME}/.config/${dir}.bak ;
  fi
  ln -sf ${PWD}/${dir} ${HOME}/.config/${dir} ;
done

if [ -d ${HOME}/.SpaceVim.d ] ; then
    mv ${HOME}/.SpaceVim.d ${HOME}/.SpaceVim.d.bak ;
fi
ln -sf ${PWD}/SpaceVim.d ${HOME}/.SpaceVim.d

# make runsvdir services dir

mkdir -p ${HOME}/.local
ln -sf ${PWD}/service ${HOME}/.local
