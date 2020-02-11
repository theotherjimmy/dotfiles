{ config, lib, pkgs, ... }:

with { colors = import ./colors.nix; }; {
  imports = [ ./mako.nix ];
  programs.home-manager.enable = true;
  home.packages = with pkgs // {
   edit = pkgs.writers.writeBashBin
    "edit"
    "exec env TERM=alacritty-direct emacsclient -c $@";
   swaystart = pkgs.writers.writeBashBin
    "startsway"
    ''
      systemctl --user import-environment
      exec systemctl --user start sway.service
    '';
  }; [
    atop
    bc
    linuxPackages.bpftrace
    direnv
    edit
    exa
    fd
    file
    firefox
    git
    gnumake
    git-hub
    git-review
    git-series
    i3status-rust
    keepass
    libnotify
    mako
    mupdf
    nixpkgs-fmt
    nix-index
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    patchelf
    procs
    pv
    ripgrep
    rofi
    swaystart
    watchexec
    xe
    xwayland
  ];
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
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
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
  # coppied from lorri module to avoid duplicating the lorri package.
  # This would be much easier if `services.lorri.package` was an option.
  systemd.user = {
    services.sway = {
      Unit = {
        description = "Sway - Wayland window manager";
        documentation = [ "man:sway(5)" ];
        bindsTo = [ "graphical-session.target" ];
        wants = [ "graphical-session-pre.target" ];
        after = [ "graphical-session-pre.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    targets.sway-session.Unit = {
      description = "Sway compositor session";
      documentation = [ "man:systemd.special(7)" ];
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };
  };

  xdg.configFile.backgrouund = {
    target = "bg.png";
    source = pkgs.runCommand "background.png" {
      src = pkgs.writeText "bg-svg" (import ./nix-snowflake.svg.nix (with colors "#"; {
        dark = bright.red;
        light = normal.cyan;
      }));
      buildInputs = [pkgs.imagemagick pkgs.potrace];
    } "convert -background none $src $out";
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
}
