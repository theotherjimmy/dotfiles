{ config, lib, pkgs, ... }:

let
  colors = config.colors.fn "#";
  bar-height = 28;
  bg-image = pkgs.runCommand "background.png" {
    src = pkgs.writeText "bg-svg" (
      import ./nix-snowflake.svg.nix (with colors; {
        dark = normal.cyan;
        light = bright.cyan;
      })
    );
    buildInputs = [pkgs.imagemagick pkgs.potrace];
  } "convert -background none $src $out";
  inherit (lib) mkOption types mkIf;
  ws-switch = let
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    rofi = "${pkgs.rofi}/bin/rofi";
  in pkgs.writers.writeBashBin "rofi-switch-workspaces" ''
       ${wmctrl} -d \
         | awk '{ print $1 " " $9}' \
         | ${rofi} -dmenu -i -p 'Switch to Workspace' \
         | awk '{ system("${wmctrl} -s " $1) }'
  '';
  ws-move = let
    xdotool = "${pkgs.xdotool}/bin/xdotool";
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    rofi = "${pkgs.rofi}/bin/rofi";
  in pkgs.writers.writeBashBin "rofi-move-workspaces" ''
       ACTIVE_WINDOW=$(${xdotool} getactivewindow)
       ${wmctrl} -d \
         | awk '{ print $1 " " $9}' \
         | ${rofi} -dmenu -i -p 'Move Foused Window to Workspace' \
         | awk "{ system(\"${wmctrl} -i -r $ACTIVE_WINDOW -t \" \$1) }"
  '';
  ws-new = let
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    rofi = "${pkgs.rofi}/bin/rofi";
    lantactl = "$HOME/src/rust/lanta/target/release/lantactl";
  in pkgs.writers.writeBashBin "rofi-new-workspace" ''
       ${wmctrl} -d \
         | awk '{ print $1 " " $9}' \
         | ${rofi} -dmenu -i -p 'New Workspace' \
         | awk ' NF == 2 { system("${lantactl} new " $2) }
                 NF == 1 { system("${lantactl} new " $1) }'
  '';
  ws-rename = let
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    rofi = "${pkgs.rofi}/bin/rofi";
    lantactl = "$HOME/src/rust/lanta/target/release/lantactl";
  in pkgs.writers.writeBashBin "rofi-rename-workspace" ''
       ${wmctrl} -d \
         | awk '{ print $1 " " $9}' \
         | ${rofi} -dmenu -i -p 'Rename Workspace' \
         | awk ' NF == 2 { system("${lantactl} rename " $2) }
                 NF == 1 { system("${lantactl} rename " $1) }'
  '';
in {
  imports = [
    ./modules/autorandr-rs.nix
    ./modules/lanta.nix
  ];
  config.services.autorandrd = {
    enable = true;
    config = ./monitors.toml;
  };
  config.lanta = {
    enable = true;
    config = pkgs.stdenv.mkDerivation {
      name = "lanta-config";
      src = ./lanta.yaml;
      unpackPhase = "true";
      buildPhase = with config.colors.fn "0x"; ''
        substitute $src $out \
          --replace "{{focus}}" "${normal.green}" \
          --replace "{{normal}}" "${primary.bg4}"
      '';
      installPhase = "true";
    };
  };
  config.services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.xtrlock-pam}/bin/xtrlock-pam";
  };
  config.services.pulseeffects = {
    enable = true;
    # Anything with "legacy" in the name is sus
    package = pkgs.pulseeffects-legacy;
  };
  config.services.polybar = with colors; {
    enable = true;
    script = "polybar main &";
    config = let line = "background"; in {
      "bar/main" = {
        width = "100%";
        height = bar-height;
        radius = 0;
        fixed-center = true;
        bottom = true;
        background = primary.background;
        foreground = primary.foreground;

        border-size = 0;
        line-size = 2;
        padding = 0;
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
        "label-active-${line}" = normal.green;
        label-active-foreground = primary.background;

        label-occupied = " %name% ";
        label-urgent = " %name% ";
        label-empty = " %name% ";
        label-empty-foreground = normal.white;
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        "format-${line}" = normal.red;
        format-foreground = primary.background;
        label = " cpu %percentage:2%% ";
      };
      "module/wlan" =  {
        type = "internal/network";
        interface = "wlp59s0";
        interval = 5;
        format-connected = "<ramp-signal> <label-connected>";
        "format-connected-${line}" = normal.magenta;
        format-connected-foreground = primary.background;
        label-connected = " %essid% ";
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
        "format-connected-${line}" = normal.magenta;
        format-connected-foreground = primary.background;
        label-connected = " eth %local_ip% ";
        format-disconnected = "";
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%a %d";
        time = "%H:%M";
        "format-${line}" = normal.blue;
        format-foreground = primary.background;
        label = " %date% %time% ";
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = 98;
        format-charging = "%percentage%%";
        "format-charging-${line}" = normal.yellow;
        format-charging-foreground = primary.background;
        format-discharging = "%percentage%%";
        "format-discharging-${line}" = normal.yellow;
        format-discharging-foreground = primary.background;
        format-full = " ☀ ";
        "format-full-${line}" = normal.green;
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
  config.systemd.user.services.background = {
    Unit = {
      Description = "Set the background for an X session";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.feh}/bin/feh --bg-center --image-bg ${colors.primary.bg-soft} ${bg-image}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  config.home.packages = with pkgs; [
    autorandr-rs
    firefox
    hack-font
    keepass
    mupdf
    xclip
    xorg.xdpyinfo
    fractal
    ws-switch
    ws-new
    ws-rename
    ws-move
  ];
}
