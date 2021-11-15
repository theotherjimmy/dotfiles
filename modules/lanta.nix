{ config, lib, pkgs, ... }:

let
  cfg = config.lanta;
  inherit (lib) mkEnableOption mkOption mkIf optionalString;
in {
  # TODO: lazy
  options.lanta = {
    enable = mkEnableOption "Lanta configuration";
    config = mkOption {
      apply = path: if lib.isStorePath path then path else builtins.path {inherit path; };
    };
  };
  config = mkIf cfg.enable (
    {
      xsession.windowManager.command = "systemd-cat -t wm -- $HOME/.cargo/bin/lanta";
      xdg.configFile."lanta/lanta.yaml".source = cfg.config;
    }
  );
}
