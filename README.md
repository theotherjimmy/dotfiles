# @theotherimmy's Unix Config

This contains both my configuration files and an installer bash scirpt for them.
The install script, `install.sh`, may be run many times, and will create a
symlink from the config location to the install clone of this repo. This is
useful as it allows me to edit the configuration in both locations.

## Included configuration

* `xinitrc` - X initialization script, using the `aur/xinit-xsession` archlinux
  package for login
* `alacritty` - X11 and Wayland terminal; [upstream](https://github.com/jwilm/alacritty)
* `dunst` - Notification Daemon
* `fish` - Shell
* `SpaceVim.d` - NeoVim configuration using the SpaceVim project; [upstream](https://github.com/SpaceVim/SpaceVim)
