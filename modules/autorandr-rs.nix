{ config, lib, pkgs, ... }:

let
  cfg = config.services.autorandrd;
  inherit (lib) mkEnableOption mkOption mkIf optionalString;
  inherit (pkgs) writeScriptBin;
in {
  options.services.autorandrd = {
    enable = mkEnableOption "monitor-layout daemon configuration";
    config = mkOption {
      description = ''The configuration file, in TOML'';
      apply = path: if lib.isStorePath path then path else builtins.path {inherit path; };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.monitor-layout = {
      Unit = {
        Description = "monitor-layout daemon: automatic display layout daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service.ExecStart = "${pkgs.monitor-layout}/bin/monitor-layout daemon ${cfg.config}";
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
