# @theotherimmy's Unix Config

This contains both my configuration files and an installer bash scirpt for them.
The install script, `install.sh`, may be run many times, and will create a
symlink from the config location to the install clone of this repo. This is
useful as it allows me to edit the configuration in both locations.

## Included configuration

* `xinitrc` - X initialization script, using the `aur/xinit-xsession` archlinux
  package for login
* `alacritty` - X11 and Wayland terminal; [upstream](https://github.com/jwilm/alacritty)
* `dunst` - Notification Daemon; requires the [centering branch](https://github.com/dunst-project/dunst/tree/centering)
* `fish` - Shell
* `SpaceVim.d` - NeoVim configuration using the SpaceVim project; [upstream](https://github.com/SpaceVim/SpaceVim)
* `userChrome.css` - Styling of the UI of firefox browser, "chrome". Removes
  the tab bar at the top, as I use tree-styl-tabs.
* `service` - Services started as part of an Xorg session

## Required Archlinux Packages
An incomplete list of archlinux packages includes:
 * `aur/polybar`, the bottom-of-my-wm bar
 * `aur/runit-systemd`, the basis of daemon starting within `xinitrc`
 * `aur/xinit-xsession`, so that you can login with gdm, etc. and run `~/.xinitrc`
 * `noto-font-*` the font used in these configs
 * `unclutter`, to remove the mouse pointer when not in use
 * `alacritty`
 * `fish`
 * `neovim`

## Wallpaper/Background

I use the wallpaper from [Nightly Nordic](https://www.reddit.com/r/unixporn/comments/caiad9/awesomewm_nighty_nordic/)
([direct link](https://mir-cdn.behance.net/v1/rendition/project_modules/fs/f585d480368685.5d22ffe9b8b5e.png))
