{ config, pkgs, lib, ... }: {
  home.packages = [
    (pkgs.callPackage ../pkgs/niriws.nix {
      runtimeEnv = {
        term = lib.getExe pkgs.foot;
      };
    })
    pkgs.sshfs
    pkgs.wl-clipboard-rs
    pkgs.wlvncc
    pkgs.shikane
    pkgs.wdisplays
    pkgs.xwayland-satellite
    pkgs.wlr-which-key
  ];
  programs.rofi = {
    enable = true;
    extraConfig.location = 2;
    theme.window.border = 2;
    theme.window.border-color = let
      inherit (config.lib.formats.rasi) mkLiteral;
      mkRgba =
        opacity': color:
        let
          c = config.lib.stylix.colors;
          r = c."${color}-rgb-r";
          g = c."${color}-rgb-g";
          b = c."${color}-rgb-b";
        in
        mkLiteral "rgba ( ${r}, ${g}, ${b}, ${opacity'} % )";
      mkRgb = mkRgba "100";
    in mkRgb "base0A";
  };
  programs.niri = {
    enable = true;
    package = pkgs.niri;
  };
  xdg.configFile."wlr-which-key/config.yaml".source = let
    c = config.lib.stylix.colors.withHashtag;
    font = config.stylix.fonts;
  in pkgs.concatText "wlr-which-key config" [
    (pkgs.writeText "wlr-which-key colors" ''
      background: "${c.base01}"
      color: "${c.base05}"
      border: "${c.base0A}"
      font: ${font.monospace.name} ${toString font.sizes.popups}
    '')
    ./wlr-which-key-config.yaml
  ];
  xdg.configFile."niri/config.kdl".source = let
    c = config.lib.stylix.colors;
  in pkgs.substitute {
    src = ./niri-config.kdl;
    substitutions = [
      "--replace" "@active@" "#${c.base0A}"
      "--replace" "@inactive@" "#${c.base03}"
      "--replace" "@background@" "#${c.base02}"
    ];
  };
  programs.ashell = {
    enable = true;
    systemd.enable = true;
    settings = {
      position = "Top";
      modules = {
        center = [ "Clock" ];
        left = [ "SystemInfo" "Tray" ];
        right = [ "Privacy" "Settings" ];
      };
      system_info.temperature.sensor = "coretemp Package id 0";
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
  services.swayidle = {
    enable = true;
    timeouts = [
      {
        timeout = 300;
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
            mode = "3440x1440@99.982Hz";
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
           (m.builtin.at 4280 1680)
           (m.samsung.at 0 0)
           (m.asus.at 840 1440)
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
           /* (m.acer.at 2560 0) */
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
