{config, pkgs, lib, ...}:

let
  bemenu-options = let
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
      (arg: val: ''--${arg} "${val}"'') colors;
    color-arg-string = lib.strings.concatStringsSep " " color-args;
  in ''-W 0.5 -c -l 30 --fixed-height -R 5 ${color-arg-string}'';
  tofi-run = "${pkgs.bemenu}/bin/bemenu-run ${bemenu-options}";
  wofi = "${pkgs.bemenu}/bin/bemenu -i ${bemenu-options}";
  term = "${pkgs.foot}/bin/foot";
  termInPwd = pwdVar: "${term} -- env -C ${pwdVar} bash";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  hyprmenu = pkgs.writers.writeBashBin "hyprmenu" ''
     ${tofi-run}
  '';
  hypr-ws-rename = pkgs.writers.writeBashBin "hypr-ws-rename" ''
    FRE_STORE=$HOME/.local/share/lanta/desktop-names
    NAME=$(fre --sorted --store $FRE_STORE | ${wofi} -p "Rename Workspace ")
    if [[ -n $NAME ]] ; then
      ID=$(${hyprctl} activeworkspace -j | jq '.id')
      SUFFIX=$(${hyprctl} activeworkspace -j | jq -r '.name' | cut -d: -s -f 2-)
      ${hyprctl} dispatch renameworkspace $ID $NAME
      fre --add "$NAME" --store $FRE_STORE
    fi
  '';
  hypr-set-pwd = pkgs.writers.writeBashBin "hypr-set-pwd" ''
    SELECTED=$(fd -d 2 -t d | ${wofi} -p "Set Workspace PWD")
    if [[ -n $SELECTED ]] ; then
      ID=$(${hyprctl} activeworkspace -j | jq '.id')
      PREFIX=$(${hyprctl} activeworkspace -j | jq -r '.name' | cut -d: -f 1)
      if [[ -n $ID ]] && [[ -n $PREFIX ]] ; then
          ${hyprctl} dispatch renameworkspace $ID $PREFIX:$SELECTED
      fi
    fi
  '';
  hypr-ws-pwd = pkgs.writers.writeBashBin "hypr-ws-pwd" ''
    CUR_WS_PWD=$(${hyprctl} activeworkspace -j | jq -r '.name' | cut -d: -s -f 2-)
    if [[ -e $CUR_WS_PWD ]] ; then
       ${termInPwd "$CUR_WS_PWD"}
    else
       ${term}
    fi
  '';
  hypr-ws-switch = pkgs.writers.writeBashBin "hypr-ws-switch" ''
    NAME=$(${hyprctl} workspaces -j | jq -r '.[] | @text "\(.id) \(.name)"' | ${wofi} -p "Switch To ")
    if [[ -n $NAME ]] ; then
      ${hyprctl} dispatch focusworkspaceoncurrentmonitor $(echo $NAME | awk '{print $1}')
    fi
  '';
  hypr-screenoff = pkgs.writers.writeBashBin "hypr-screenoff" ''
    sleep 1 && ${hyprctl} dispatch dpms off
  '';
in {
    home.packages = [
        pkgs.bemenu
        hyprmenu
        hypr-set-pwd
        hypr-ws-rename
        hypr-ws-switch
        hypr-ws-pwd
        pkgs.helvum
        pkgs.wl-clipboard-rs
        pkgs.wayvnc
        pkgs.wlvncc
    ];
    programs.waybar = {
        enable = true;
        systemd.enable = true;
        settings = {
          mainBar = {
            layer = "top";
            position = "bottom";
            height = 30;
            modules-left = [ "cpu" "memory" "temperature" "battery"];
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
        borderRadius = 5;
        borderSize = 2;
    };
    services.network-manager-applet.enable = true;
    services.udiskie = {
      enable = true;
      tray = "always";
    };
    systemd.user.services.wayvnc = {
      Install.WantedBy = ["graphical-session.target"];
      Unit.PartOf = ["graphical-session.target"];
      Service.ExecStart = "${pkgs.lib.getExe pkgs.wayvnc} -g -f 60";
    };
    programs.swaylock.enable = true;
    xdg.configFile."tofi/config" = {
        enable = true;
        text = ''
          width = 100%
          height = 100%
          border-width = 0
          outline-width = 0
          padding-left = 35%
          padding-top = 35%
          result-spacing = 25
          num-results = 12
          font = monospace
          background-color = #000A
        '';
    };
    xdg.portal = {
      enable = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-hyprland
      ];
    };
    wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = let
          colors = config.colors.fn "0xff";
          foot = "${pkgs.foot}"/bin/foot;
          mkMonitor = desc: res: loc: scale: rotate: lib.strings.trim ''
            monitor=desc:${desc},${res},${loc},${toString scale},bitdepth,8${lib.strings.optionalString rotate ",transform,1"}
            workspace = m[desc:${desc}], layoutopt:orientation:${if rotate then "top" else "center"}
          '';
        in ''
          env AQ_MGPU_NO_EXPLICIT=1
          $mod = Alt
          bind = $mod and Shift, C, exec, foot
          bind = $mod, C, exec, hypr-ws-pwd
          bind = $mod, G, exec, hypr-ws-switch
          bind = $mod, N, workspace, empty
          bind = $mod, R, exec, hypr-ws-rename
          bind = $mod and Shift, R, exec, hypr-set-pwd
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
          bindm = $mod, mouse:272, movewindow
          bindm = $mod, mouse:273, resizewindow

          ${mkMonitor "Acer Technologies Acer K272HUL T0SAA0014200" "2560x1440" "0x0" 1 false}
          ${mkMonitor "Samsung Electric Company S27D850 HCJH901332" "2560x1440" "0x1440" 1 false}

          ${mkMonitor "Ancor Communications Inc ASUS PB278 E5LMTF100243" "2560x1440" "0x0" 1 false}
          ${mkMonitor "Samsung Display Corp. 0x4164" "3840x2400" "0x1440" 2 false}

          ${mkMonitor "Lenovo Group Limited TIO24Gen4 V308MBXM" "1920x1080@74.97" "2250x0" 1 true}
          ${mkMonitor "Lenovo Group Limited P24h-30 V90E1R50" "2560x1440@74.78" "-310x0" 1 false}
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
