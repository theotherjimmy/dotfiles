{ config, lib, pkgs, ... }:

let
  colors = config.colors.fn;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = { lines = 0; columns = 0; };
        padding = { x = 5; y = 5; };
        dynamic_padding = true;
        dynamic_title = true;
        decorations = "none";
      };
      font = {
        normal.family = config.font.name;
        size = config.font.em;
        offset = { x = 0; y = 0; };
      };
      draw_bold_text_with_bright_colors = true;
      colors = colors "0x";
      bell.duration = 0;
      background_opacity = 1.0;
      mouse_bindings = [ { mouse = "Middle"; action = "PasteSelection"; } ];
      mouse.url.launcher = "firefox";
      live_config_reload = true;
      shell = { program = "fish"; args = [ "--login" ]; };
      key_bindings = [
        { key = "V"; mods = "Control|Shift"; action = "Paste"; }
        { key = "C"; mods = "Control|Shift"; action = "Copy"; }
        { key = "Paste"; action = "Paste"; }
        { key = "Copy"; action = "Copy"; }
        { key = "Insert"; mods = "Shift"; action = "PasteSelection"; }
        { key = "Key0"; mods = "Control"; action = "ResetFontSize"; }
        { key = "Equals"; mods = "Control"; action = "IncreaseFontSize"; }
        { key = "Minus"; mods = "Control"; action = "DecreaseFontSize"; }
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
  programs.termite = with colors "#"; {
    enable = true;
    cursorColor = primary.foreground;
    font = config.font.emstr;
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
      font = config.font.emstr;
      guioptions = "cs";
      adjust-open = "width";
      incremental-search = "false";
      recolor = "true";
      recolor-reverse-video = "false";
      statusbar-home-tilde = "true";
      selection-clipboard = "primary";

      completion-fg = primary.foreground;
      completion-bg = primary.background;
      completion-group-fg = primary.foreground;
      completion-group-bg = primary.bg-soft;
      completion-highlight-fg = normal.green;
      completion-highlight-bg = primary.bg-soft;
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
  programs.doom-emacs= {
    enable = true;
    doomPrivateDir = ./doom-emacs/doom.d;
    emacsPackage = pkgs.emacs;
  };
  services.emacs.enable = true;
  programs.firefox = {
    enable = true;
  };
  programs.rofi = {
    enable = true;
    borderWidth = 2;
    font = config.font.emstr;
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
  gtk.enable = true;
  gtk.iconTheme.name = "Adwaita";
  gtk.iconTheme.package = pkgs.gnome3.adwaita-icon-theme;
  gtk.theme.name = "gruvbox-gtk";
  gtk.theme.package = pkgs.stdenv.mkDerivation rec {
    pname = "gruvbox-gtk";
    version = "master";

    src = pkgs.fetchFromGitHub {
      owner  = "3ximus";
      repo   = pname;
      rev    = "fda45c127bd5ed3cdd2dfcc6c396e7aef99abd8e";
      sha256 = "1vlgsp7hgf96bzlj54rimmimzhpchh3z3a4fll71wxghr3gpv27d";
    };

    nativeBuildInputs = with pkgs; [
      pkgconfig
      sassc
      optipng
      librsvg
      inkscape
      gtk3
    ];

    propagatedUserEnvPkgs = [ pkgs.gtk-engine-murrine ];

    enableParallelBuilding = false;

    installPhase = ''
      mkdir -p $out/share/themes/${pname}
      cp -a . $out/share/themes/${pname}
    '';
  };
}
