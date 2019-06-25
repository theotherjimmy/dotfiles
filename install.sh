#!/bin/bash
BASEDIR=$(dirname $0)
cd ${BASEDIR}

ln -sf ${PWD}/xinitrc ${HOME}/.xinitrc

mkdir -p ${HOME}/.config
if [ -d ${HOME}/.config/alacritty ] ; then
  mv ${HOME}/.config/alacritty ${HOME}/.config/alacritty.bak ;
fi
ln -sf ${PWD}/alacritty ${HOME}/.config/alacritty
