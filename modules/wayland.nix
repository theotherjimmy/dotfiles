{ config, pkgs, lib, ... }:

let
  bemenu-options =
    let
      c = config.colors.fn "#";
      colors = {
        tf = c.base0B;
        tb = c.base02;
        ff = c.base08;
        fb = c.base02;
        cf = c.base07;
        cb = c.base02;
        nf = c.base07;
        nb = c.base02;
        af = c.base07;
        ab = c.base02;
        hf = c.base0D;
        hb = c.base03;
        sf = c.base0D;
        sb = c.base02;
      };
      color-args = lib.attrsets.mapAttrsToList
        (arg: val: ''--${arg} ${val}'')
        colors;
      color-arg-string = lib.strings.concatStringsSep " " color-args;
    in
    ''-i -W 0.5 -c -l 30 --fixed-height -R 5 ${color-arg-string}'';
  tofi-run = ''BEMENU_OPTS="${bemenu-options}" ${pkgs.bemenu}/bin/bemenu-run'';
  term = lib.getExe pkgs.foot;
  hyprctl = lib.getExe config.wayland.windowManager.hyprland.package;
  hyprmenu = pkgs.writers.writeBashBin "hyprmenu" ''
    ${tofi-run}
  '';
  hypr-screenoff = pkgs.writers.writeBashBin "hypr-screenoff" ''
    sleep 1 && ${hyprctl} dispatch dpms off
  '';
in
{
  home.packages = [
    (pkgs.callPackage ../pkgs/hyprws.nix {
      runtimeEnv = {
        inherit term;
        BEMENU_OPTS = bemenu-options;
      };
    })
    pkgs.sshfs
    pkgs.bemenu
    hyprmenu
    pkgs.helvum
    pkgs.wl-clipboard-rs
    pkgs.wayvnc
    pkgs.wlvncc
    pkgs.shikane
  ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 30;
        modules-left = [ "cpu" "memory" "temperature" "battery" ];
        modules-center = [ "hyprland/workspaces" ];
        modules-right = [ "wireplumber" "tray" "clock" ];
        clock.format = "{:%A %F %H:%M}";
        cpu.format = "{min_frequency:0.1f}Ghz ⇋ {max_frequency:0.1f}Ghz";
        memory.format = "{used:0.1f}G/{total:0.1f}G";
        "hyprland/workspaces" = {
          format = "{name}";
          active-only = true;
        };
        temperature = {
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon9/temp1_input";
          tooltip = false;
        };
        wireplumber.format = "Vol: {volume}";
        battery.format = "Bat: {capacity}%";
      };
    };
    style = let c = config.colors.fn "#"; in ''
      * {
          padding: 0 10px;
          border: none;
          border-radius: 10;
          font-size: 18px;
      }
      window#waybar {
          background: transparent;
      }
      .modules-left {
          padding: 0 10px;
          border: 2px solid ${c.base0D};
          background-color: ${c.base00};
      }
      .modules-center {
          padding: 0 10px;
          border: 2px solid ${c.base09};
          background-color: ${c.base00};
      }
      .modules-right {
          padding: 0 10px;
          border: 2px solid ${c.base0E};
          background-color: ${c.base00};
      }
    '';
  };
  services.mako = {
    enable = true;
    settings = {
      border-radius = 5;
      border-size = 2;
    };
  };
  services.network-manager-applet.enable = true;
  services.udiskie = {
    enable = true;
    tray = "always";
  };
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
  };
  services.shikane = {
    enable = true;
    settings = {
      profile = [
       {
         name = "work-home";
         output = [
           {
             match = "eDP-1";
             enable = true;
             mode = "3840x2400@60Hz";
             position = { x = 0; y = 1440; };
             scale = 2.0;
           }
           {
             enable = true;
             search = [ "m=S27D850" "s=HCJH901332" ];
             mode = "2560x1440@59.951Hz";
             position = { x = 1920; y = 1440; };
           }
           {
             enable = true;
             search = ["m=Acer K272HUL" "s=T0SAA0014200" ];
             mode = "2560x1440@59.951Hz";
             position = { x = 1920; y = 0; };
           }
         ];
       }
       {
         name = "work-home-but-the-dock-is-a-piece-of-shit";
         output = [
           {
             match = "eDP-1";
             enable = true;
             mode = "3840x2400@60Hz";
             position = { x = 0; y = 1440; };
             scale = 2.0;
           }
           {
             enable = true;
             search = [ "m=S27D850" "s=HCJH901332" ];
             mode = "2560x1440@59.951Hz";
             position = { x = 1920; y = 1440; };
           }
           {
             enable = false;
             search = ["m=No Monitor"];
           }
         ];
       }
       {
         name = "work-home-but-the-dock-is-a-piece-of-shit";
         output = [
           {
             match = "eDP-1";
             enable = true;
             mode = "3840x2400@60Hz";
             position = { x = 0; y = 1440; };
             scale = 2.0;
           }
           {
             enable = true;
             search = [ "m=S27D850" "s=HCJH901332" ];
             mode = "2560x1440@59.951Hz";
             position = { x = 1920; y = 1440; };
           }
         ];
       }
       {
         name = "office";
         output = [
           {
             match = "eDP-1";
             enable = true;
             mode = "3840x2400@60Hz";
             position = { x = 0; y = 1440; };
             scale = 2.0;
           }
           {
             enable = true;
             search = [ "m=P24h-30" "s=V90E1R50" ];
             mode = "2560x1440@74.78Hz";
             position = { x = 0; y = 0; };
           }
           {
             enable = true;
             search = [ "m=TIO24Gen4" "s=V308MBXM" ];
             mode = "1920x1080@74.97";
             position = { x = 2560; y = 0; };
           }
         ];
       }
       {
         name = "houston";
         output = [
           { # Top
             enable = true;
             search = [ "m=LG HDR 4K" "s=410NTFAAN987" ];
             mode = "3840x2160@60Hz";
             position = { x = 0; y = 0; };
           }
           { # Bottom
             match = "eDP-1";
             enable = true;
             mode = "3840x2400@60Hz";
             position = { x = 960; y = 2160; };
             scale = 2.0;
           }
           { # Right
             enable = true;
             search = [ "m=LA2405" "s=CN41221D84" ];
             mode = "1920x1200@59.95Hz";
             position = { x = 3840; y = 600; };
           }
         ];
       }
       {
         name = "houston-alt";
         output = [
           {
             match = "eDP-1";
             enable = true;
             mode = "3840x2400@60Hz";
             position = { x = 0; y = 1440; };
             scale = 2.0;
           }
           {
             enable = true;
             search = [ "m=VG34VQL3A" "s=SCLMDW019741" ];
             mode = "3440x1440@99.98Hz";
             position = { x = -760; y = 0; };
           }
         ];
       }
       {
         name = "builtin-monitor-only";
         output = [
           {
             match = "eDP-1";
             enable = true;
           }
         ];
       }
     ];
    };
  };
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig =
      let
        colors = config.colors.fn "0xff";
        foot = "${pkgs.foot}" /bin/foot;
        mkMonitor = desc: res: loc: scale: rotate: lib.strings.trim ''
          monitor=desc:${desc},${res},${loc},${toString scale},bitdepth,8${lib.strings.optionalString rotate ",transform,1"}
          workspace = m[desc:${desc}], layoutopt:orientation:${if rotate then "top" else "center"}
        '';
      in
      ''
        env AQ_MGPU_NO_EXPLICIT=1
        $mod = Alt
        bind = $mod and Shift, C, exec, foot fish
        bind = $mod, C, exec, hyprws term
        bind = $mod, E, exec, hyprws edit
        bind = $mod, G, exec, hyprws switch
        bind = $mod and Shift, G, exec, hyprws move-to
        bind = $mod, N, workspace, empty
        bind = $mod, N, exec, hyprws rename
        bind = $mod, M, layoutmsg, addmaster
        bind = $mod and Shift, M, layoutmsg, removemaster
        bind = $mod and Shift, N, movetoworkspace, empty
        bind = $mod and Shift, N, exec, hyprws rename
        bind = $mod, R, exec, hyprws rename
        bind = $mod and Shift, R, exec, hyprws set-pwd
        bind = $mod, P, exec, hyprmenu
        bind = $mod, H, movefocus, l
        bind = $mod, J, movefocus, d
        bind = $mod, K, movefocus, u
        bind = $mod, L, movefocus, r
        bind = $mod, F, togglefloating,
        bind = $mod and Shift, H, swapwindow, l
        bind = $mod and Shift, J, swapwindow, d
        bind = $mod and Shift, K, swapwindow, u
        bind = $mod and Shift, L, swapwindow, r
        bind = $mod, D, killactive,
        bind = $mod, Return, fullscreen, 1
        bind = $mod and Shift, Return, fullscreen, 0
        bind = $mod and Shift, S, exec, sleep 1 && hyprctl dispatch dpms off
        bind = $mod and Control, S, exec, systemctl suspend
        bindm = $mod, mouse:272, movewindow
        bindm = $mod, mouse:273, resizewindow

        animation = global, 1, 1, default
        animation = workspaces, 1, 1, default, fade

        general {
            layout = master
            border_size = 3
            gaps_out = 0
            col.inactive_border = ${colors.base02}
            col.active_border = ${colors.base0B}
        }

        decoration {
            rounding = 10
        }

        input {
            kb_layout = us,us
            kb_variant = dvp,
            kb_options = caps:escape
        }

        master {
            orientation = center
            mfact = 0.4
            new_on_active = after
        }
        workspace = m:desc:Ancor Communications Inc ASUS PB278 E5LMTF100243, layoutopt:orientation:top

        misc {
            key_press_enables_dpms = true
        }
      '';
  };
}
