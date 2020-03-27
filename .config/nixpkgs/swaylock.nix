{ config, lib, pkgs, ... }:

with lib // { cfg = config.programs.swaylock; }; {
  options.programs.swaylock = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the mako wayland notification daemon";
    };
    image = mkOption {
      type = types.str;
      description = "Display the given image.";
    };
    scaling = mkOption {
      type = types.enum [ "stretch" "fill" "fit" "center" "tile" "solid_color" ];
      default = "fit";
      description = ''
        Image scaling mode: stretch, fill, fit, center, tile, solid_color. Use
        solid_color to display only the background color, even if a background
        image is specified.
      '';
    };
    color = mkOption {
      type = types.str;
      default = "FFFFFF";
      description = ''
        Turn the screen into the given color instead of white.
        If wayland.windowManager.swaylock.image is used, this sets the background
        of the image to the given color.
      '';
    };
  };
  config.xdg.configFile.swaylock = mkIf cfg.enable {
      target = "swaylock/config";
      text = ''
        ${generators.toKeyValue {} (filterAttrs (n: _: n != "enable") cfg)}
      '';
  };
}
