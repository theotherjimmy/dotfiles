{ config, lib, pkgs, ... }:

with lib; {
  options.font = {
    name = mkOption {
      type = types.str;
      default = "Hack";
      description = "Font name";
    };
    em = mkOption {
      type = types.int;
      default = 11;
      description = "The size of the font in points";
    };
    px = mkOption {
      type = types.int;
      default = 16;
      description = "The size of the font in pixels";
    };
    emstr = mkOption {
      type = types.str;
      default = "";
      description = "Don't set";
    };
  };
  config.font.emstr = "${config.font.name} ${toString config.font.em}";
  config.home.packages = [
    (pkgs.nerdfonts.override {fonts = [config.font.name];})
    # Noto fonts used as backup for now
    pkgs.noto-fonts
    pkgs.noto-fonts-emoji
    pkgs.noto-fonts-cjk
    pkgs.noto-fonts-extra
  ];
  config.fonts.fontconfig.enable = true;
}

