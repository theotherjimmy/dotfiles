{ lib, ... } : {
  imports = [
    ./colors.nix
    ./wayland.nix
    ./font.nix
    ./gui-apps.nix
    ./cli-apps.nix
  ];
  home = {
    homeDirectory = lib.mkForce "/home/jimbri01";
    username = "jimbri01";
    stateVersion = "22.11";
  };
  colors.theme = "gruvbox-dark";
  xsession.enable = false;
  systemd.user.startServices = true;
  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = [ "caps:escape" ];
  };
}
