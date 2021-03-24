{ config, lib, pkgs, ... }:

let
  cfg = config.services.xidlehook;
  inherit (lib) mkEnableOption mkOption mkIf concatMapStringsSep types
    optionalString;
  inherit (pkgs) writeScriptBin;
  mkHook = {seconds, minutes, hours, hook-on, hook-off}:
    let
      timeout = seconds + minutes * 60 + hours * 60 * 60;
    in "--timer ${toString timeout} '${hook-on}' '${hook-off}'";
  timerModule = types.submodule {
    options = {
      seconds = mkOption { type = types.int; default = 0; };
      minutes = mkOption { type = types.int; default = 0; };
      hours = mkOption { type = types.int; default = 0; };
      hook-on = mkOption { type = types.str; default = ""; };
      hook-off = mkOption { type = types.str; default = ""; };
    };
  };
in {
  options.services.xidlehook = {
    enable = mkEnableOption "xidlehook configuration";
    not-when-fullscreen = mkEnableOption "consider fullscreen activity";
    not-when-audio = mkEnableOption "consider audio activity";
    timers = mkOption {
      type = types.listOf timerModule;
    };
  };
  config = mkIf cfg.enable (
    let
      service-name = "run-xidlehook-service";
      exec-str =
        "${pkgs.xidlehook}/bin/xidlehook "
        + (optionalString cfg.not-when-fullscreen "--not-when-fullscreen ")
        + (optionalString cfg.not-when-audio "--not-when-audio ")
        + (concatMapStringsSep " " mkHook cfg.timers);
    in {
      systemd.user.services.xidlehook = {
        Unit = {
          Description = "Run commands on Xorg idle timeouts";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service.ExecStart = exec-str;
        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
  );
}
