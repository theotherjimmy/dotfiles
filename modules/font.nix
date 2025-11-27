{ config, lib, pkgs, ... }:

with lib; {
  options.font = {
    name = mkOption {
      type = types.str;
      default = "Hack";
      description = "Font name";
    };
    pkg-name = mkOption {
      type = types.str;
      default = lib.strings.toLower config.font.name;
    };
    font-conf-name = mkOption {
      type = types.str;
      default = "${config.font.name}NerdFontMono";
      description = "Font name expected by font-config";
    };
    em = mkOption {
      type = types.int;
      default = 11;
      description = "The size of the font in points";
    };
    line-height = mkOption {
      type = types.int;
      default = config.font.em;
      description = "The line height of the font in points";
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
  config.font.emstr = "${config.font.font-conf-name} ${toString config.font.em}";
  config.home.packages = [
    pkgs.nerd-fonts."${config.font.pkg-name}"
    # Noto fonts used as backup for now
    pkgs.noto-fonts
    pkgs.noto-fonts-color-emoji
    pkgs.noto-fonts-cjk-sans
  ];
  config.fonts.fontconfig.enable = true;
}

