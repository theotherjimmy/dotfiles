{ config, lib, pkgs, ... }:

{
  imports = [
    ./colors.nix
    ./font.nix
    ./dwm.nix
    ./gui-apps.nix
    ./cli-apps.nix
  ];
  programs.home-manager.enable = true;
  xsession.enable = true;
  xsession.background.enable = true;
  colors.theme = "gruvbox-dark";
  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = ["caps:escape"];
  };
}
