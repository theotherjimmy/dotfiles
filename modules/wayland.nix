{config, pkgs, ...}:

let
  tofi-run = "${pkgs.wofi}/bin/wofi -i --show run";
  wofi = "${pkgs.wofi}/bin/wofi -d -i";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  hyprmenu = pkgs.writers.writeBashBin "hyprmenu" ''
     ${tofi-run}
  '';
  hypr-ws-rename = pkgs.writers.writeBashBin "hypr-ws-rename" ''
    FRE_STORE=$HOME/.local/share/lanta/desktop-names
    NAME=$(fre --sorted --store $FRE_STORE | ${wofi} -p "Rename Workspace ")
    if [[ -n $NAME ]] ; then
      ID=$(${hyprctl} activeworkspace -j | jq '.id')
      ${hyprctl} dispatch renameworkspace $ID $NAME
      fre --add "$NAME" --store $FRE_STORE
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
        pkgs.wofi
        hyprmenu
        hypr-ws-rename
        hypr-ws-switch
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
            output = [
              "DP-1"
              "DP-4"
            ];
            modules-left = [ "cpu" "memory" "temperature" ];
            modules-center = [ "hyprland/submap" ];
            modules-right = [ "tray" "clock" ];
            cpu.format = "{min_frequency}Ghz ⇋ {max_frequency}Ghz";
            "hyprland/submap".format = "╞ {} ╡";
          };
        };
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
    wayland.windowManager.hyprland = {
        enable = true;
        extraConfig = let colors = config.colors.fn "0xff"; in ''
          $mod = Alt
          bind = $mod, C, exec, foot
          bind = $mod, G, exec, hypr-ws-switch
          bind = $mod, N, workspace, empty
          bind = $mod, R, exec, hypr-ws-rename
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

          monitor=desc:Acer Technologies Acer K272HUL T0SAA0014200,2560x1440,0x0,1,bitdepth,8
          workspace = m[desc:Acer Technologies Acer K272HUL T0SAA0014200], layoutopt:orientation:center
          monitor=desc:Samsung Electric Company S27D850 HCJH901332,2560x1440,0x1440,1,bitdepth,8
          workspace = m[desc:Samsung Electric Company S27D850 HCJH901332], layoutopt:orientation:center
          monitor=desc:Ancor Communications Inc ASUS PB278 E5LMTF100243,2560x1440,2560x320,1,bitdepth,8,transform,1
          workspace = m[desc:Ancor Communications Inc ASUS PB278 E5LMTF100243], layoutopt:orientation:top

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
          layerrule=noanim,wofi

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
