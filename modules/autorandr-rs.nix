{ config, lib, pkgs, ... }:

let
  cfg = config.services.autorandrd;
  inherit (lib) mkEnableOption mkOption mkIf optionalString;
  inherit (pkgs) writeScriptBin;
in {
  options.services.autorandrd = {
    enable = mkEnableOption "autorandr-rs configuration";
    config = mkOption {
      description = ''The configuration file, in TOML'';
      apply = path: if lib.isStorePath path then path else builtins.path {inherit path; };
    };
    enableNotifications = mkEnableOption "notify of display changes through notify-send";
  };
  config = mkIf cfg.enable (
    let
      service-name = "run-autorandrd-service";
      exec = writeScriptBin service-name
        (''#!/bin/sh
           ${pkgs.autorandr-rs}/bin/autorandrd ${cfg.config}'' + (optionalString cfg.enableNotifications
             # TODO: This seems to fail to send notifications. Don't know why.
             '' | while read cfg ; do ${pkgs.libnotify}/bin/notify-send "$cfg" ; done''
          )
        );
    in {
      systemd.user.services.autorandrd = {
        Unit = {
          Description = "autorandr-rs: automatic display configuration daemon";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
        Service.ExecStart = "${exec}/bin/${service-name}";
        Install.WantedBy = [ "graphical-session.target" ];
      };
    }
  );
}
