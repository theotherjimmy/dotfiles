{ config, lib, pkgs, ... }:

let
  colors = config.colors.fn "#";
  bar-height = 28;
  bg-image = pkgs.runCommand "background.png" {
    src = pkgs.writeText "bg-svg" (
      import ./nix-snowflake.svg.nix {
        dark = colors.base04;
        light = colors.base05;
      }
    );
    buildInputs = [pkgs.imagemagick pkgs.potrace];
  } "convert -background none $src $out";
  inherit (lib) mkOption types mkIf;
  lanta = "$HOME/.cargo/bin/lanta";
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
  in pkgs.writers.writeBashBin "rofi-new-workspace" ''
    FRE_STORE=$HOME/.local/share/lanta/desktop-names
    NAME=$(fre --sorted --store $FRE_STORE | rofi -dmenu -i -p 'New Workspace')
    if [[ $? == 0 ]] ; then
      lanta new $NAME
      fre --add "$NAME" --store $FRE_STORE
    fi
  '';
  ws-new-from-wd = let
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    rofi = "${pkgs.rofi}/bin/rofi";
  in pkgs.writers.writeBashBin "rofi-new-workspace-from-wd" ''
    NAME=$(fd -t d -d 4 | rofi -dmenu -i -p 'New Workspace')
    if [[ $? == 0 ]] ; then
      lanta new-from-wd $NAME
    fi
  '';
  ws-rename = let
    wmctrl = "${pkgs.wmctrl}/bin/wmctrl";
    rofi = "${pkgs.rofi}/bin/rofi";
  in pkgs.writers.writeBashBin "rofi-rename-workspace" ''
    FRE_STORE=$HOME/.local/share/lanta/desktop-names
    NAME=$(fre --sorted --store $FRE_STORE | rofi -dmenu -i -p 'Rename Workspace')
    if [[ $? == 0 ]] ; then
      lanta rename $NAME
      fre --add "$NAME" --store $FRE_STORE
    fi
  '';
in {
  imports = [
    ./modules/autorandr-rs.nix
    ./modules/lanta.nix
  ];
  config.services.autorandrd = {
    enable = true;
    config = ./monitors.kdl;
  };
  config.home.sessionPath = ["$HOME/.cargo/bin"];
  config.lanta = {
    enable = true;
    config = pkgs.stdenv.mkDerivation {
      name = "lanta-config";
      src = ./lanta.yaml;
      unpackPhase = "true";
      buildPhase = let inherit (config.colors.fn "0x") base0B base02; in ''
        substitute $src $out \
          --replace "{{focus}}" "${base0B}" \
          --replace "{{normal}}" "${base02}" \
          --replace "{{bashInteractive}}" "${pkgs.bashInteractive}/bin/bash"
      '';
      installPhase = "true";
    };
  };
  config.services.polybar = {
    enable = true;
    script = "polybar main &";
    config = let line = "background"; in {
      "bar/main" = {
        width = "100%";
        height = bar-height;
        radius = 0;
        fixed-center = true;
        bottom = true;
        background = colors.base00;
        foreground = colors.base05;

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
        "label-active-${line}" = colors.base0B;
        label-active-foreground = colors.base00;

        label-occupied = " %name% ";
        label-urgent = " %name% ";
        label-empty = " %name% ";
        label-empty-foreground = colors.base04;
      };
      "module/cpu" = {
        type = "internal/cpu";
        interval = 2;
        "format-${line}" = colors.base08;
        format-foreground = colors.base00;
        label = " cpu %percentage:2%% ";
      };
      "module/wlan" =  {
        type = "internal/network";
        interface = "wlp59s0";
        interval = 5;
        format-connected = "<ramp-signal> <label-connected>";
        "format-connected-${line}" = colors.base0E;
        format-connected-foreground = colors.base00;
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
        "format-connected-${line}" = colors.base0E;
        format-connected-foreground = colors.base00;
        label-connected = " eth %local_ip% ";
        format-disconnected = "";
      };
      "module/date" = {
        type = "internal/date";
        interval = 5;
        date = "%a %d";
        time = "%H:%M";
        "format-${line}" = colors.base0D;
        format-foreground = colors.base00;
        label = " %date% %time% ";
      };
      "module/battery" = {
        type = "internal/battery";
        battery = "BAT0";
        adapter = "AC";
        full-at = 98;
        time-format = "%H:%M";
        format-charging = "<label-charging>";
        label-charging = "☝%percentage%%—%time%";
        "format-charging-${line}" = colors.base0A;
        format-charging-foreground = colors.base00;
        format-discharging = "<label-discharging>";
        label-discharging = "☟%percentage%%—%time%";
        "format-discharging-${line}" = colors.base0A;
        format-discharging-foreground = colors.base00;
        format-full = " ☀ ";
        "format-full-${line}" = colors.base0B;
      };
      settings.screenchange-reload = true;
    };
  };
  config.services.unclutter.enable = true;
  config.services.redshift = {
    enable = true;
    latitude = "30.3126259";
    longitude = "-97.7407611";
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
      ExecStart = "${pkgs.feh}/bin/feh --bg-center --image-bg ${colors.base02} ${bg-image}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  config.home.packages = [
    pkgs.hack-font
    pkgs.keepass
    pkgs.monitor-layout
    pkgs.mupdf
    pkgs.xclip
    pkgs.xorg.xdpyinfo
    pkgs.fre
    pkgs.gnuplot
    ws-switch
    ws-new
    ws-new-from-wd
    ws-rename
    ws-move
  ];
}
