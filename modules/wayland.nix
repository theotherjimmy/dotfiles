{ config, pkgs, lib, ... }:

let
  bemenu-options =
    let
      c = config.colors.fn "#";
      colors = {
        tf = c.base09;
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
    (pkgs.callPackage ../pkgs/niriws.nix {
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
    pkgs.niri
    pkgs.xwayland-satellite
    pkgs.swww
  ];
  xdg.configFile."niri/config.kdl".source = let
    c = config.colors.fn "#";
  in pkgs.substitute {
    src = ./niri-config.kdl;
    substitutions = [
      "--replace" "@active@" c.base09
      "--replace" "@inactive@" c.base02
    ];
  };
  programs.waybar = {
    enable = true;
    systemd.enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "bottom";
        height = 40;
        modules-left = [ "cpu" "memory" "temperature" "battery" ];
        modules-center = [ "hyprland/workspaces" "niri/workspaces" ];
        modules-right = [ "wireplumber" "tray" "clock" ];
        clock.format = "{:%A %F %H:%M}";
        cpu.format = "{min_frequency:0.1f}Ghz ⇋ {max_frequency:0.1f}Ghz";
        memory.format = "{used:0.1f}G/{total:0.1f}G";
        "hyprland/workspaces" = {
          format = "{name}";
          active-only = true;
        };
        "niri/workspaces" = {
          current-only = true;
        };
        temperature = {
          hwmon-path = "/sys/devices/platform/coretemp.0/hwmon/hwmon9/temp1_input";
          tooltip = false;
        };
        tray.spacing = 5;
        wireplumber.format = "Vol: {volume}";
        battery.format = "Bat: {capacity}%";
      };
    };
    style = let c = config.colors.fn "#"; in ''
      * {
          border: none;
          font-size: ${toString config.font.px}px;
          font-family: ${config.font.font-conf-name};
      }
      window#waybar {
          background: transparent;
      }
      .module {
          border: 2px solid ${c.base02};
          background: ${c.base00};
          padding: 0 10px;
          color: ${c.base07};
      }
      #workspaces button {
          color: ${c.base07};
      }
    '';
  };
  services.mako = {
    enable = true;
    settings = let c = config.colors.fn "#"; in {
      border-radius = 0;
      border-size = 2;
      border-color = c.base0D;
      background-color = c.base00;
      text-color = c.base07;
      icons = true;
      default-timeout = 10000;
      anchor = "top-center";
    };
  };
  services.network-manager-applet.enable = true;
  services.udiskie = {
    enable = true;
    tray = "always";
  };
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 60;
        command = "${pkgs.niri}/bin/niri msg action power-off-monitors";
      }
    ];
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
      profile = let
        backing = {
          builtin = {
            match = "eDP-1";
            enable = true;
            mode = "3840x2400@60Hz";
            scale = 2.0;
          };
          samsung = {
            enable = true;
            search = [ "m=S27D850" "s=HCJH901332" ];
            mode = "2560x1440@59.951Hz";
          };
          acer = {
            enable = true;
            search = ["m=Acer K272HUL" "s=T0SAA0014200" ];
            mode = "2560x1440@59.951Hz";
          };
          thinkvision = {
            enable = true;
            search = [ "m=P24h-30" "s=V90E1R50" ];
            mode = "2560x1440@74.78Hz";
          };
          thinkcenter ={
            enable = true;
            search = [ "m=TIO24Gen4" "s=V308MBXM" ];
            mode = "1920x1080@74.97";
          };
          hp = {
            enable = true;
            search = [ "m=LA2405" "s=CN41221D84" ];
            mode = "1920x1200@59.95Hz";
          };
          asus = {
            enable = true;
            search = [ "m=VG34VQL3A" "s=SCLMDW019741" ];
            mode = "3440x1440@165.00Hz";
          };
          no-monitor = { search = ["m=No Monitor"]; };
        };
        m = lib.attrsets.mapAttrs (name: val: {
          at = x: y: val // { position = { x = x; y = y; }; };
          off = val // { enable = false; };
        }) backing;
      in [
       {
         name = "work-home";
         output = [
           (m.builtin.at 0 1440)
           (m.samsung.at (1920 - 320) 0)
           (m.asus.at 1920 1440)
         ];
       }
       {
         name = "work-home-but-the-dock-is-a-piece-of-shit";
         output = [
           (m.builtin.at 0 1440)
           (m.samsung.at 1920 1440)
           m.no-monitor.off
         ];
       }
       {
         name = "work-home-but-the-dock-is-a-piece-of-shit";
         output = [
           (m.builtin.at 0 1440)
           (m.samsung.at 1920 1440)
         ];
       }
       {
         name = "office";
         output = [
           (m.builtin.at 0 1440)
           (m.thinkvision.at 0 0)
           (m.thinkcenter.at 2560 0)
         ];
       }
       {
         name = "houston-bedroom";
         output = [
           (m.builtin.at 0 1200)
           (m.hp.at 320 0)
         ];
       }
       {
         name = "nixboi";
         output = [
           (m.samsung.at 0 0)
           (m.acer.at 2560 0)
           (m.asus.at 860 1440)
         ];
       }
       {
         name = "builtin-monitor-only";
         output = [(m.builtin.at 0 0)];
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
        $mod = Alt
        bind = $mod and Shift, C, exec, foot fish
        bind = $mod, C, exec, hyprws term
        bind = $mod, E, exec, hyprws edit
        bind = $mod, G, exec, hyprws switch
        bind = $mod and Shift, G, exec, hyprws move-to
        bind = $mod and Control, G, workspace, previous
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
        bind = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-
        bind = ,XF86MonBrightnessUp, exec, brightnessctl s +10%
        bindm = $mod, mouse:272, movewindow
        bindm = $mod, mouse:273, resizewindow

        animation = global, 1, 1, default
        animation = workspaces, 1, 1, default, fade

        general {
            layout = master
            border_size = 3
            gaps_out = 0
            col.inactive_border = ${colors.base02}
            col.active_border = ${colors.base09}
        }

        decoration {
            rounding = 0
        }

        input {
            kb_layout = us,us
            kb_variant = dvp,
            kb_options = caps:escape
            float_switch_override_focus = 0
        }

        master {
            orientation = center
            mfact = 0.4
            new_on_active = after
        }

        misc {
            key_press_enables_dpms = true
        }

        debug {
            disable_logs = false
        }
      '';
  };
}
