#!/usr/bin/bash
BASEDIR=$(dirname $0)
cd ${BASEDIR}

ln -sf ${PWD}/xinitrc ${HOME}/.xinitrc

mkdir -p ${HOME}/.config

if [ -d ${HOME}/.config/alacritty ] ; then
  mv ${HOME}/.config/alacritty ${HOME}/.config/alacritty.bak ;
fi
ln -sf ${PWD}/alacritty ${HOME}/.config/alacritty

if [ -d ${HOME}/.config/fish ] ; then
  mv ${HOME}/.config/fish ${HOME}/.config/fish.bak ;
fi
ln -sf ${PWD}/fish ${HOME}/.config/fish

if [ -d ${HOME}/.SpaceVim.d ] ; then
    mv ${HOME}/.SpaceVim.d ${HOME}/.SpaceVim.d.bak ;
fi
ln -sf ${PWD}/SpaceVim.d ${HOME}/.SpaceVim.d
