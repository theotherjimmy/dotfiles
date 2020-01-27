{ config, lib, pkgs, ... }:

with lib // { cfg = config.services.mako; }; {
  options.services.mako = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the mako wayland notification daemon";
    };
    generic = mkOption {
      type = types.attrsOf (types.oneOf [ types.ints.positive types.str ]);
      default = {};
      description = "An attribute set describing the global configuration options";
    };
    criteria = mkOption {
      type = types.attrsOf (types.attrsOf (types.oneOf [ types.ints.positive types.str ]));
      default = {};
      description = "A mapping from criteria to attribute sets describing configuration options";
    };
  };
  config = {
    systemd.user.services.mako = mkIf cfg.enable {
      Unit = {
        Description = "mako wayland notification daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Install.WantedBy = [ "graphical-session.target" ];

      Service = {
        ExecStart = "${pkgs.mako}/bin/mako";
        BusName = "org.freedesktop.Notifications";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        Restart = "on-failure";
      };
    };
    xdg.configFile.mako = {
      target = "mako/config";
      text = ''
        ${generators.toKeyValue {} cfg.generic}
        ${generators.toINI {} cfg.criteria}
      '';
    };
  };
}

