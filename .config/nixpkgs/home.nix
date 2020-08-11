{ config, lib, pkgs, ... }:

let
  font = rec {
    name = "Hack";
    em = 11;
    px = 16;
    emstr = "${name} ${toString em}";
  };
  colors = import ./colors.nix;
  bg-image = pkgs.runCommand "background.png" {
    src = pkgs.writeText "bg-svg" (import ./nix-snowflake.svg.nix (with colors "#"; {
      dark = normal.red;
      light = normal.cyan;
    }));
    buildInputs = [pkgs.imagemagick pkgs.potrace];
  } "convert -background none $src $out";
  dwm = pkgs.callPackage /home/jimbri01/src/nix/dwm/package.nix {
    inherit colors font;
  };
in {
  imports = [ ];
  programs.home-manager.enable = true;
  home.packages = with pkgs // rec {
    edit = pkgs.writers.writeBashBin "edit" ''
      if [[ -n $NVIM_LISTEN_ADDRESS ]] ; then
        exec nvr $@
      else
        exec nvim $@
      fi
    '';
    edit-wait = pkgs.writers.writeBashBin "edit-wait" ''
      if [[ -n $NVIM_LISTEN_ADDRESS ]] ; then
        exec nvr --remote-wait $@
      else
        exec nvim $@
      fi
    '';
    git-ip-review = pkgs.writeShellScriptBin "git-ip-review" ''
      rev=$(git rev-parse --abbrev-ref HEAD)
      if [ "HEAD" == $rev ] ; then
        echo "Error: detached HEAD; Refusing to push an ip review"
        exit 1
      else
        git push arm $rev:refs/for/master/$rev
      fi
    '';
  }; [
    aspell
    acpilight
    apitrace
    atop
    bc
    linuxPackages.bpftrace
    direnv
    edit
    edit-wait
    exa
    fd
    file
    firefox
    fractal
    fzf #Note: remove this when Spacevim can call skim
    git
    gnumake
    git-hub
    git-ip-review
    git-review
    git-series
    just
    keepass
    libnotify
    mupdf
    niv
    nixpkgs-fmt
    nix-top
    nix-index
    nix-prefetch-scripts
    neovim
    neovim-remote
    hack-font
    (nerdfonts.override {fonts = ["Hack"];})
    noto-fonts
    patchelf
    procs
    pv
    usbutils
    ripgrep
    rofi
    screen
    tmux
    watchexec
    wl-clipboard
    xclip
    xe
    xmlstarlet
    xwayland
    xorg.xdpyinfo
  ];
  fonts.fontconfig.enable = true;
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = { lines = 0; columns = 0; };
        padding = { x = 5; y = 5; };
        dynamic_padding = true;
        decorations = "none";
      };
      font = {
        normal.family = font.name;
        size = font.em;
        offset = { x = 0; y = 0; };
      };
      draw_bold_text_with_bright_colors = true;
      colors = colors "0x";
      visual_bell.duration = 0;
      background_opacity = 1.0;
      mouse_bindings = [ { mouse = "Middle"; action = "PasteSelection"; } ];
      mouse.url.launcher = "firefox";
      dynamic_title = true;
      live_config_reload = true;
      shell = { program = "fish"; args = [ "--login" ]; };
      key_bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Paste"; action = "Paste"; }
        { key = "Copy"; action = "Copy"; }
        { key = "Q"; mods = "Command"; action = "Quit"; }
        { key = "W"; mods = "Command"; action = "Quit"; }
        { key = "Insert"; mods = "Shift"; action = "PasteSelection"; }
        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Subtract"; mods = "Control"; action = "DecreaseFontSize"; }
        { key = "L"; mods = "Control"; action = "ClearLogNotice"; }
        { key = "L"; mods = "Control"; chars = "\\x0c"; }
        { key = "Home"; chars = "\\x1bOH"; mode = "AppCursor"; }
        { key = "Home"; chars = "\\x1b[H"; mode = "~AppCursor"; }
        { key = "End"; chars = "\\x1bOF"; mode = "AppCursor"; }
        { key = "End"; chars = "\\x1b[F"; mode = "~AppCursor"; }
        { key = "PageUp"; mods = "Shift"; chars = ''\x1b[5";2~''; }
        { key = "PageUp"; mods = "Control"; chars = ''\x1b[5";5~''; }
        { key = "PageUp"; chars = "\\x1b[5~"; }
        { key = "PageDown"; mods = "Shift"; chars = ''\x1b[6";2~''; }
        { key = "PageDown"; mods = "Control"; chars = ''\x1b[6";5~''; }
        { key = "PageDown"; chars = "\\x1b[6~"; }
        { key = "Tab"; mods = "Shift"; chars = "\\x1b[Z"; }
        { key = "Back"; chars = "\\x7f"; }
        { key = "Back"; mods = "Alt"; chars = "\\x1b\\x7f"; }
        { key = "Insert"; chars = "\\x1b[2~"; }
        { key = "Delete"; chars = "\\x1b[3~"; }
        { key = "Left"; mods = "Shift"; chars = ''\x1b[1";2D''; }
        { key = "Left"; mods = "Control"; chars = ''\x1b[1";5D''; }
        { key = "Left"; mods = "Alt"; chars = ''\x1b[1";3D''; }
        { key = "Left"; chars = "\\x1b[D"; mode = "~AppCursor"; }
        { key = "Left"; chars = "\\x1bOD"; mode = "AppCursor"; }
        { key = "Right"; mods = "Shift"; chars = ''\x1b[1";2C''; }
        { key = "Right"; mods = "Control"; chars = ''\x1b[1";5C''; }
        { key = "Right"; mods = "Alt"; chars = ''\x1b[1";3C''; }
        { key = "Right"; chars = "\\x1b[C"; mode = "~AppCursor"; }
        { key = "Right"; chars = "\\x1bOC"; mode = "AppCursor"; }
        { key = "Up"; mods = "Shift"; chars = ''\x1b[1";2A''; }
        { key = "Up"; mods = "Control"; chars = ''\x1b[1";5A''; }
        { key = "Up"; mods = "Alt"; chars = ''\x1b[1";3A''; }
        { key = "Up"; chars = "\\x1b[A"; mode = "~AppCursor"; }
        { key = "Up"; chars = "\\x1bOA"; mode = "AppCursor"; }
        { key = "Down"; mods = "Shift"; chars = ''\x1b[1";2B''; }
        { key = "Down"; mods = "Control"; chars = ''\x1b[1";5B''; }
        { key = "Down"; mods = "Alt"; chars = ''\x1b[1";3B''; }
        { key = "Down"; chars = "\\x1b[B"; mode = "~AppCursor"; }
        { key = "Down"; chars = "\\x1bOB"; mode = "AppCursor"; }
      ];
    };
  };
  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };
  programs.firefox = {
    enable = true;
  };
  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "exa";
      pd = "prevd";
      nd = "nextd";
      j = "just";
    };
  };
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = false;
      prompt_order = [
        "directory"
        "nix_shell"
        "git_branch"
        "git_state"
        "cmd_duration"
        "line_break"
        "character"
      ];
      scan_timeout = 6;
      cmd_duration.min_time = 10;
      cmd_duration.show_milliseconds = true;
      character.symbol = "➜";
      directory.truncation_length = 1;
      directory.fish_style_pwd_dir_length = 1;
    };
  };
  programs.git = {
    enable = true;
    aliases = {
      ds = "diff --staged";
      ap = "add -p";
    };
    extraConfig.core.editor = "edit-wait";
    ignores = [ ".direnv.d" ".envrc" "shell.nix" ];
    userEmail = "theotherjimmy@gmail.com";
    userName = "Jimmy Brisson";
  };
  programs.htop = {
    enable = true;
    fields = [
      "PID"
      "USER"
      "M_SIZE"
      "M_RESIDENT"
      "M_SHARE"
      "STATE"
      "PERCENT_CPU"
      "PERCENT_MEM"
      "TIME"
      "COMM"
    ];
    hideUserlandThreads = true;
    highlightBaseName = true;
    meters.left = [ "AllCPUs" "Memory" ];
    treeView = true;
  };
  programs.jq.enable = true;
  programs.man.enable = true;
  programs.skim.enable = true;
  programs.termite = with colors "#"; {
    enable = true;
    cursorColor = primary.foreground;
    font = font.emstr;
    foregroundColor = primary.foreground;
    backgroundColor = primary.background;
    colorsExtra = ''
      color0 = ${normal.black}
      color8 = ${bright.black}
      color1 = ${normal.red}
      color9 = ${bright.red}
      color2 = ${normal.green}
      color10 = ${bright.green}
      color3 = ${normal.yellow}
      color11 = ${bright.yellow}
      color4 = ${normal.blue}
      color12 = ${bright.blue}
      color5 = ${normal.magenta}
      color13 = ${bright.magenta}
      color6 = ${normal.cyan}
      color14 = ${bright.cyan}
      color7 = ${normal.white}
      color15 = ${bright.white}
    '';
  };
  programs.zathura = {
    enable = true;
    options = with colors "#"; {
      font = font.emstr;
      guioptions = "cs";
      adjust-open = "width";
      incremental-search = "false";
      recolor = "true";
      recolor-reverse-video = "false";
      statusbar-home-tilde = "true";
      selection-clipboard = "primary";

      completion-fg = primary.foreground;
      completion-bg = primary.bg-soft;
      completion-group-fg = primary.foreground;
      completion-group-bg = primary.background;
      completion-highlight-bg = bright.blue;
      completion-highlight-fg = primary.foreground;
      default-fg = primary.foreground;
      default-bg = primary.background;
      inputbar-fg = primary.foreground;
      inputbar-bg = primary.background;
      notification-bg = primary.background;
      notification-fg = primary.foreground;
      notification-error-bg = primary.background;
      notification-error-fg = normal.red;
      notification-warning-bg = primary.background;
      notification-warning-fg = normal.yellow;
      tabbar-bg = primary.background;
      tabbar-fg = normal.blue;
      tabbar-focus-bg = normal.white;
      tabbar-focus-fg = primary.background;
      statusbar-bg = primary.bg-soft;
      statusbar-fg = primary.foreground;
      highlight-color = normal.yellow;
      highlight-active-color = primary.foreground;
      recolor-darkcolor = primary.foreground;
      recolor-lightcolor = primary.background;
      render-loading-bg = primary.background;
      render-loading-fg = primary.foreground;
      index-bg = primary.background;
      index-fg = primary.foreground;
      index-active-bg = primary.bg-soft;
      index-active-fg = normal.green;
    };
  };
  services.polybar = with colors "#"; {
    enable = true;
    script = "polybar main &";
    config = {
      "bar/main" = {
        width = "100%";
        height = 35;
        radius = 0;
        fixed-center = true;
        bottom = false;
        background = primary.background;
        foreground = primary.foreground;

        border-size = 0;
        line-size = 2;
        padding = 1;
        module-margin = 1;

        font-0 = "${font.name}:size=${toString font.em}";
        font-1 = "${font.name}:size=${toString font.em}";
        font-2 = "Noto Sans Symbols:size=16";
        font-3 = "Noto Sans Symbols2:size=16";

        modules-right = "ewmh date";
        modules-center = "xwindow";
        modules-left = "battery cpu eth wlan";

        tray-position = "right";
        tray-padding = 2;
        tray-maxsize = 24;
        override-redirect = true;
      };
      "global/wm".margin-top = 0;
      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:100:...%";
        format-underline = normal.cyan;
      };
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
  services.picom.enable = true;
  services.unclutter.enable = true;
  systemd.user.services.background = {
    Unit = {
      Description = "Set the background for an X session";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = with colors "#"; 
        "${pkgs.feh}/bin/feh --bg-center --image-bg ${primary.bg-soft} ${bg-image}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
  services.lorri.enable = true;
  services.emacs.enable = true;
  services.redshift = {
    package = pkgs.redshift-wlr;
    enable = true;
    brightness.day = "0.9";
    brightness.night = "0.6";
    latitude = "30.3126259";
    longitude = "-97.7407611";
  };
  services.udiskie.enable = true;
  services.dunst = {
    enable = true;
    settings = with colors "#"; {
      global = {
        geometry = "500x5-0+20";
        padding = 10;
        frame_width = 2;
        frame_color = normal.cyan;
        font = font.emstr;
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
  home.file.".emacs.d" = {
    # don't make the directory read only so that impure melpa can still happen
    # for now
    recursive = true;
    source = pkgs.fetchFromGitHub {
      owner = "syl20bnr";
      repo = "spacemacs";
      rev = "26b8fe0c317915b622825877eb5e5bdae88fb2b2";
      sha256 = "00cfm6caaz85rwlrbs8rm2878wgnph6342i9688w4dji3dgyz3rz";
    };
  };
  xsession.enable = true;
  home.keyboard = {
    layout = "us";
    variant = "dvp";
    options = ["caps:escape"];
  };
  xsession.windowManager.command = "${dwm}/bin/dwm";
  programs.rofi = {
    enable = true;
    borderWidth = 2;
    font = font.emstr;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    lines = 20;
    separator = "solid";
    colors = with colors "#"; {
      window = {
        inherit (primary) background;
        border = normal.white;
        separator = normal.white;
      };
      rows = {
        active = {
          background = normal.yellow;
          backgroundAlt = normal.yellow;
          foreground = primary.background;
          highlight = {
            background = bright.yellow;
            foreground = primary.background;
          };
        };
        urgent = {
          background = normal.red;
          backgroundAlt = normal.red;
          foreground = primary.background;
          highlight = {
            background = bright.red;
            foreground = primary.background;
          };
        };
        normal = {
          inherit (primary) background foreground;
          backgroundAlt = primary.bg-soft;
          highlight = {
            inherit (primary) foreground;
            background = normal.white;
          };
        };
      };
    };
  };
}
