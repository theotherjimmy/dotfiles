{ config, lib, pkgs, ... }:

with rec {
  colors = import ./colors.nix;
  bg-image = pkgs.runCommand "background.png" {
    src = pkgs.writeText "bg-svg" (import ./nix-snowflake.svg.nix (with colors "#"; {
      dark = normal.red;
      light = normal.cyan;
    }));
    buildInputs = [pkgs.imagemagick pkgs.potrace];
  } "convert -background none $src $out";
  wm-config = with colors "#"; {
    bars = [{
      position = "top";
      statusCommand = "${pkgs.i3status-rust}/bin/i3status-rs .config/sway/status.toml";
      workspaceNumbers = false;
      fonts = [ "noto sans mono 11" ];
      colors = let mkWorkspace =
        border: {
          inherit border;
          inherit (primary) background;
          text = primary.foreground;
        };
      in {
        inherit (primary) background;
        statusline = primary.foreground;
        focusedWorkspace = mkWorkspace bright.red;
        inactiveWorkspace = mkWorkspace primary.background;
        urgentWorkspace = mkWorkspace normal.cyan;
      };
    }];
    colors = let mkColors =
      border: {
        inherit (primary) background;
        text = primary.foreground;
        inherit border;
        childBorder = border;
        indicator = border;
      };
    in {
      inherit (primary) background;
      focused = mkColors normal.cyan;
      focusedInactive = mkColors primary.background;
      unfocused = mkColors primary.background;
    };
    focus.followMouse = false;
    fonts = [ "noto sans mono 11" ];
    gaps = {
      inner = 10;
      outer = 10;
      smartBorders = "on";
      smartGaps = true;
    };
    keybindings = let
      modifier = "Mod1";
      ws1 = "1:#";
      ws2 = "2:[";
      ws3 = "3:{";
      ws4 = "4:}";
      ws5 = "5:(";
      ws6 = "6:=";
      ws7 = "7:*";
      ws8 = "8:)";
      ws9 = "9:+";
      ws10 = "10:]";
    in {
      "${modifier}+c" = "exec alacritty";
      "${modifier}+Shift+semicolon" = "kill";
      "${modifier}+p" = "exec rofi -show run";
      "${modifier}+h" = "focus left";
      "${modifier}+j" = "focus down";
      "${modifier}+k" = "focus up";
      "${modifier}+l" = "focus right";
      "${modifier}+Shift+h" = "move left";
      "${modifier}+Shift+j" = "move down";
      "${modifier}+Shift+k" = "move up";
      "${modifier}+Shift+l" = "move right";
      "${modifier}+d" = "split h";
      "${modifier}+v" = "split v";
      "${modifier}+u" = "fullscreen toggle";
      "${modifier}+w" = "workspace back_and_forth";
      "${modifier}+o" = "layout tabbed";
      "${modifier}+period" = "layout toggle split";

      "${modifier}+Shift+r" = "reload";
      "${modifier}+Shift+p" = "restart";
      "${modifier}+Shift+period" = ''exec "swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit sway' 'swaymsg exit'"'';
      "${modifier}+Shift+s" = "exec loginctl lock-session auto";
      # switch to workspace
      "${modifier}+ampersand" = "workspace number ${ws1}";
      "${modifier}+bracketleft" = "workspace number ${ws2}";
      "${modifier}+braceleft" ="workspace number ${ws3}";
      "${modifier}+braceright" = "workspace number ${ws4}";
      "${modifier}+parenleft" = "workspace number ${ws5}";
      "${modifier}+equal" = "workspace number ${ws6}";
      "${modifier}+asterisk" = "workspace number ${ws7}";
      "${modifier}+parenright" = "workspace number ${ws8}";
      "${modifier}+plus" = "workspace number ${ws9}";
      "${modifier}+bracketright" = "workspace number ${ws10}";
      # move focused container to workspace
      "${modifier}+Shift+ampersand" = "move container to workspace number ${ws1}";
      "${modifier}+Shift+bracketleft" = "move container to workspace number ${ws2}";
      "${modifier}+Shift+braceleft" = "move container to workspace number ${ws3}";
      "${modifier}+Shift+braceright" = "move container to workspace number ${ws4}";
      "${modifier}+Shift+parenleft" = "move container to workspace number ${ws5}";
      "${modifier}+Shift+equal" = "move container to workspace number ${ws6}";
      "${modifier}+Shift+asterisk" = "move container to workspace number ${ws7}";
      "${modifier}+Shift+parenright" = "move container to workspace number ${ws8}";
      "${modifier}+Shift+plus" = "move container to workspace number ${ws9}";
      "${modifier}+Shift+bracketright" = "move container to workspace number ${ws10}";
    };
    window = {
      border = 2;
      titlebar = true;
    };
  };
}; {
  imports = [
    ./mako.nix
    ./swaylock.nix
  ];
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
    mako
    mupdf
    nixpkgs-fmt
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
    ripgrep
    rofi
    screen
    swaystart
    watchexec
    wl-clipboard
    xe
    xwayland
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
      tabspaces = 8;
      font = {
        normal.family = "Noto Sans Mono";
        size = 11.0;
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
    font = "Noto Sans Mono 11";
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
  services.mako = with colors "#"; {
    enable = true;
    generic =  {
      font="Noto Sans Mono 10";
      border-size = 3;
      padding = 10;
      default-timeout = 5000;
      background-color = primary.background;
      text-color = primary.foreground;
      border-color = normal.red;
    };
    criteria = {
      "urgency=high".border-color = bright.red;
      "urgency=low".border-color = normal.yellow;
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
  wayland.windowManager.sway.config = wm-config // {
    input = {
      "type:keyboard" = {
        xkb_layout = "us";
        xkb_variant = "dvp";
        xkb_options = "caps:escape";
      };
      "type:touchpad" = {
        dwt = "enabled";
        natural_scroll = "enabled";
        middle_emulation = "enabled";
      };
    };
    output."*" = with colors "#"; {
      bg = "${bg-image} center ${primary.bg-soft}";
    };
  };
  wayland.windowManager.sway.enable = true;
  wayland.windowManager.sway.extraConfig = ''
    titlebar_border_thickness 2
    seat * hide_cursor 1000
    title_align center
    for_window [shell=".*"] title_format "%title :: %shell"
  '';
  xsession.windowManager.i3 = {
    enable = true;
    extraConfig = ''
      default_border normal 2
      title_align center
      for_window [class="^.*"] border normal 2
    '';
    config = wm-config // {
      startup = [{
        command = "${pkgs.feh}/bin/feh --bg-center -B ${(colors "#").primary.bg-soft} ${bg-image}";
        always = true;
      }];
    };
  };
  programs.swaylock = with colors ""; {
    enable = true;
    image = "${bg-image}";
    scaling = "center";
    color = primary.bg-soft;
  };
  programs.rofi = {
    enable = true;
    borderWidth = 2;
    font = "Noto Sans Mono 11";
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
