{ config, pkgs, lib, ... }: {
  home.packages = [
    (pkgs.callPackage ../pkgs/niriws.nix {
      runtimeEnv = {
        term = lib.getExe pkgs.foot;
      };
    })
    pkgs.sshfs
    pkgs.helvum
    pkgs.wl-clipboard-rs
    pkgs.wlvncc
    pkgs.shikane
    pkgs.xwayland-satellite
  ];
  programs.rofi.enable = true;
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  xdg.configFile."niri/config.kdl".source = let
    c = config.lib.stylix.colors;
  in pkgs.substitute {
    src = ./niri-config.kdl;
    substitutions = [
      "--replace" "@active@" "#${c.base0A}"
      "--replace" "@inactive@" "#${c.base03}"
    ];
  };
  services.swww.enable = true;
  programs.ashell = {
    enable = true;
    systemd.enable = true;
    settings = {
      position = "Bottom";
      modules = {
        center = [ "Workspaces" ];
        left = [ "SystemInfo" "Tray" ];
        right = [ "Clock" "Privacy" "Settings" ];
      };
      systemInfo.temperature.sensor = "coretemp Package id 0";
      workspaces.visibilityMode = "MonitorSpecificExclusive";
      clock.format = "%F %X";
    };
  };
  services.mako = {
    enable = true;
    settings = {
      border-radius = 0;
      border-size = 2;
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
      pkgs.xdg-desktop-portal-gnome
    ];
    configPackages = [
      pkgs.xdg-desktop-portal-gnome
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
            mode = "3440x1440@119.991Hz";
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
           m.builtin.off
           (m.samsung.at (1920 - 320) 0)
           (m.asus.at 1920 1440)
         ];
       }
       {
         name = "work-home";
         output = [
           m.builtin.off
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
           (m.hp.at 0 0)
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
}
