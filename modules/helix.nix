{ config, lib, pkgs, ... }:

let
  cfg = config.programs.helix;
  inherit (lib) mkEnableOption mkOption mkIf optionalString;
  toml = pkgs.formats.toml {};
in {
  # TODO: lazy
  options.programs.helix = {
    enable = mkEnableOption "helix configuration";
    config = mkOption {
      inherit (toml) type;
    };
    theme = mkOption {
      inherit (toml) type;
    };
  };
  config = mkIf cfg.enable ({
    home.packages = [ pkgs.helix-nightly ];
    xdg.configFile."helix/config.toml".source = toml.generate "helix-config.toml" cfg.config;
    xdg.configFile."helix/themes/nix-generated.toml".source = toml.generate "helix-theme.toml" cfg.theme;
  });
}
