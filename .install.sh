#!/usr/bin/bash
git clone --bare git@github.com:theotherjimmy/dotfiles.git .cfg
function config {
   git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

mkdir -p .config-backup
config checkout
if [ $? = 0 ]; then
  echo "Checked out config.";
  else
    echo "Backing up pre-existing dot files.";
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
fi;
config checkout
config config status.showUntrackedFiles no

function link {
  echo "$2 -> $1"
  ln -sf $1 $2
}

for profile in $(echo ${HOME}/.mozilla/firefox/*default ) ; do
  mkdir -p ${profile}/chrome
  link ${HOME}/.userChrome.css ${profile}/chrome/userChrome.css
done

# make lockscreen background
echo "Creating lockscreen background -> ${HOME}/.config/lock.png"
convert -size 2560x1440 canvas:none -font "Noto-Sans-Mono-Bold" -pointsize 120\
  -fill \#3c3836 -gravity center -draw "text 0,-250 \"$(id -un) @ $(hostname)\""\
  ${HOME}/.config/lock.png
