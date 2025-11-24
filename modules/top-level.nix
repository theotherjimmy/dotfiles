{ lib, ... }: {
  imports = [
    ./colors.nix
    ./wayland.nix
    ./font.nix
    ./gui-apps.nix
    ./cli-apps.nix
    ./entertainment.nix
  ];
  home = {
    homeDirectory = lib.mkForce "/home/jimbri01";
    username = "jimbri01";
    stateVersion = "22.11";
  };
  font.em = 10;
  colors.theme = "zenburn";
  xsession.enable = false;
  systemd.user.startServices = true;
  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = [ "caps:escape" ];
  };
}
