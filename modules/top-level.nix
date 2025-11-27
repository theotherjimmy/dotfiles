{ lib, pkgs, ... }: {
  imports = [
    ./wayland.nix
    ./gui-apps.nix
    ./cli-apps.nix
    ./entertainment.nix
  ];
  home = {
    homeDirectory = lib.mkForce "/home/jimbri01";
    username = "jimbri01";
    stateVersion = "22.11";
  };
  xsession.enable = false;
  systemd.user.startServices = true;
  stylix = {
    enable = true;
    autoEnable = true;
    base16Scheme =
      #"${pkgs.base16-schemes}/share/themes/embers.yaml" # Very Desat
      #"${pkgs.base16-schemes}/share/themes/mountain.yaml" # black metal but good
      #"${pkgs.base16-schemes}/share/themes/jabuti.yaml" # purple
      #"${pkgs.base16-schemes}/share/themes/nebula.yaml" # faintly purple
      #"${pkgs.base16-schemes}/share/themes/nova.yaml" # light blue & orange
      #"${pkgs.base16-schemes}/share/themes/rose-pine.yaml" # very dark purple
      #"${pkgs.base16-schemes}/share/themes/tarot.yaml" # dark purple to salmon      #"${pkgs.base16-schemes}/share/themes/caroline.yaml" # very red, with more red
      #"${pkgs.base16-schemes}/share/themes/everforest.yaml" # plesently blue to green
      #"${pkgs.base16-schemes}/share/themes/terracotta-dark.yaml" # brown w/ green highlights
      #"${pkgs.base16-schemes}/share/themes/valua.yaml" # green w/ yellow, green & purple
      "${pkgs.base16-schemes}/share/themes/vulcan.yaml" # dark blue & orange highlights
    ;
  };
  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = [ "caps:escape" ];
  };
}
