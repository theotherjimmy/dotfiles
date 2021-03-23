{ config, lib, pkgs, ... }:

let
  colors = config.colors.fn "#";
  bar-height = 35;
  bg-image = pkgs.runCommand "background.png" {
    src = pkgs.writeText "bg-svg" (
      import ./nix-snowflake.svg.nix (with colors; {
        dark = normal.blue;
        light = bright.blue;
      })
    );
    buildInputs = [pkgs.imagemagick pkgs.potrace];
  } "convert -background none $src $out";
  inherit (lib) mkOption types mkIf;
  oneShot = desc: exec: {
    Unit = {
      Description = desc;
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = exec;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  xmonad-config =
    let
      ghcWithPackages = pkgs.haskellPackages.ghcWithPackages;
      packages = self: [
        self.xmonad-contrib
        self.xmonad-extras
        self.megaparsec
        self.void
      ];
      xmonadAndPackages = self: [ self.xmonad ] ++ packages self;
      xmonadEnv = ghcWithPackages xmonadAndPackages;
      configured = pkgs.writers.writeHaskellBin "xmonad" {
        ghc = pkgs.haskellPackages.ghc;
        libraries = xmonadAndPackages pkgs.haskellPackages;
      } (import ./xmonad.hs.nix colors);
    in
      pkgs.runCommandLocal "xmonad" {
        nativeBuildInputs = [ pkgs.makeWrapper ];
      } ''
        install -D ${xmonadEnv}/share/man/man1/xmonad.1.gz $out/share/man/man1/xmonad.1.gz
        makeWrapper ${configured}/bin/xmonad $out/bin/xmonad \
          --set NIX_GHC "${xmonadEnv}/bin/ghc" \
          --set XMONAD_XMESSAGE "${pkgs.xorg.xmessage}/bin/xmessage"
      '';
in {
  imports = [ ./modules/autorandr-rs.nix ];
  config.services.autorandr-rs = {
    enable = true;
    config = ./monitors.toml;
    enableNotifications = true;
  };
  config.xsession.windowManager.command = "systemd-cat -t xmonad -- ${xmonad-config}/bin/xmonad";
  config.services.polybar = with colors; {
    enable = true;
    script = "polybar main &";
    config = {
      "bar/main" = {
        width = "100%";
        height = bar-height;
        radius = 0;
        fixed-center = true;
        bottom = false;
        background = primary.background;
        foreground = primary.foreground;

        border-size = 0;
        line-size = 2;
        padding = 1;
        module-margin = 1;

        font-0 = "${config.font.name}:size=${toString config.font.em}";
        font-1 = "${config.font.name}:size=${toString config.font.em}";
        font-2 = "Noto Sans Symbols:size=16";
        font-3 = "Noto Sans Symbols2:size=16";

        modules-right = "cpu date";
        modules-center = "ewmh";
        modules-left = "battery eth wlan";

        tray-position = "right";
        tray-padding = 2;
        tray-maxsize = 24;
        override-redirect = true;
      };
      "global/wm".margin-top = 0;
      "module/ewmh" = {
        type = "internal/xworkspaces";
        pin-workspaces = false;
        enable-click = false;
        enable-scroll = false;

        label-active = " %name% ";
        label-active-underline = normal.red;

        label-occupied = " %name% ";
        label-urgent = " %name% ";
        label-empty = " %name% ";
        label-empty-foreground = normal.white;
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        format-prefix = "💻 ";
        format-prefix-foreground = primary.foreground;
        format-underline = normal.red;
        label = "%percentage:2%%";
      };
      "module/wlan" =  {
        type = "internal/network";
        interface = "wlp59s0";
        interval = 5;
        format-connected = "<ramp-signal> <label-connected>";
        format-connected-underline = normal.magenta;
        label-connected = "%essid%";
        label-disconnected = "";
        ramp-signal-0 = "🌧";
        ramp-signal-1 = "🌦";
        ramp-signal-2 = "🌥";
        ramp-signal-3 = "🌤";
        ramp-signal-4 = "🌣";
      };
      "module/eth" = {
        type = "internal/network";
        interface = "eno1";
        interval = 5;
        format-connected-underline = normal.magenta;
        format-connected-prefix = "🖧 ";
        format-connected-prefix-foreground = primary.foreground;
        label-connected = "%local_ip%";
        format-disconnected = "";
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%a %d";
        time = "%H:%M";
        format-prefix = "";
        format-prefix-foreground = primary.foreground;
        format-underline = normal.blue;
        label = "%date% %time%";
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = 98;
        format-charging = "%percentage%%";
        format-charging-underline = normal.yellow;
        format-discharging = "%percentage%%";
        format-discharging-underline = normal.yellow;
        format-full = " ☀ ";
        format-full-underline = normal.green;
        ramp-capacity-0 = "⚋";
        ramp-capacity-1 = "⚊";
        ramp-capacity-2 = "⚍";
        ramp-capacity-3 = "⚌";
        ramp-capacity-foreground = primary.foreground;
      };
      settings.screenchange-reload = true;
    };
  };
  config.services.unclutter.enable = true;
  config.services.redshift = {
    package = pkgs.redshift-wlr;
    enable = true;
    latitude = "30.3126259";
    longitude = "-97.7407611";
  };
  config.services.udiskie.enable = true;
  config.services.dunst = {
    enable = true;
    settings = with colors; {
      global = {
        geometry = "500x5-0+${toString bar-height}";
        padding = 10;
        frame_width = 2;
        frame_color = normal.cyan;
        font = config.font.emstr;
        align = "left";
        word_wrap = true;
      };
      urgency_low = {
        inherit (primary) foreground background;
        frame_color = normal.yellow;
      };
      urgency_medium = {
        inherit (primary) foreground background;
        frame_color = normal.cyan;
      };
      urgency_high = {
        inherit (primary) foreground background;
        frame_color = normal.red;
      };
    };
  };
  config.systemd.user.services.background = oneShot
    "Set the background for an X session"
    "${pkgs.feh}/bin/feh --bg-center --image-bg ${colors.primary.bg-soft} ${bg-image}";
  config.home.packages = [
    # Mostly for the man files.
    pkgs.autorandr-rs
  ];
}
