{ config, lib, pkgs, ... }:

let
  colors = config.colors.fn;
in {
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "discord" "zoom"
  ];
  home.packages =  with pkgs; [ discord zoom-us wezterm-nightly ];
  xdg.configFile."wezterm/wezterm.lua".text = with colors "#"; ''
    local wezterm = require 'wezterm';
    return {
      colors = {
        foreground = "${primary.foreground}",
        background = "${primary.background}",
        cursor_bg = "${primary.fg4}",
        cursor_border = "${primary.fg4}",
        cursor_fg = "${primary.background}",
        selection_bg = "${primary.fg4}",
        selection_fg = "${primary.bg4}",
        ansi = {
          "${normal.black}", "${normal.red}", "${normal.green}", "${normal.yellow}",
          "${normal.blue}", "${normal.magenta}", "${normal.cyan}", "${normal.white}"
        },
        brights = {
          "${bright.black}", "${bright.red}", "${bright.green}", "${bright.yellow}",
          "${bright.blue}", "${bright.magenta}", "${bright.cyan}", "${bright.white}"
        },
      },
      font = wezterm.font("${config.font.name}", {bold=false}),
      font_size = 13,
      dpi = 96.0,
      enable_tab_bar = false,
      window_padding = {
        left = 5,
        right = 5,
        top = 5,
        bottom = 5,
      }
    }
  '';
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
      live_config_reload = true;
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
  programs.firefox = {
    enable = true;
  };
  programs.rofi = {
    enable = true;
    font = config.font.emstr;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    separator = "solid";
    theme = with { inherit (config.lib.formats.rasi) mkLiteral; } // colors "#"; {
      "*" = {
        background-color = mkLiteral primary.background;
        border-color = normal.magenta;
      };
      window = {
        border = 2;
        padding = 2;
        anchor = mkLiteral "center";
      };
      mainbox = {
        border = 0;
        padding = 0;
      };
      textbox = {
        highlight = mkLiteral "bold italic";
        text-color = mkLiteral primary.foreground;
      };
      listview = {
        border = mkLiteral "2px solid 0 0";
        padding = mkLiteral "2px 0 0";
        border-color = mkLiteral normal.magenta;
        spacing = mkLiteral "2px";
        scrollbar = mkLiteral normal.magenta;
        lines = 20;
      };
      element = {
        border = 0;
        padding = mkLiteral "2px";
      };

      "element.normal.normal" = {
        text-color = mkLiteral primary.foreground;
      };
      "element.alternate.normal" = {
        background-color = mkLiteral primary.bg-soft;
        text-color = mkLiteral primary.foreground;
      };
      "element.selected.normal" = {
        text-color = mkLiteral normal.green;
      };

      "element.normal.active" = {
        background-color = mkLiteral normal.yellow;
        text-color = mkLiteral primary.background;
      };
      "element.alternate.active" = {
        background-color = mkLiteral normal.yellow;
        text-color = mkLiteral primary.bg-soft;
      };
      "element.selected.active" = {
        background-color = mkLiteral bright.yellow;
        text-color = mkLiteral primary.background;
      };

      "element.normal.urgent" = {
        background-color = mkLiteral normal.red;
        text-color = mkLiteral primary.background;
      };
      "element.alternate.urgent" = {
        background-color = mkLiteral normal.red;
        text-color = mkLiteral primary.bg-soft;
      };
      "element.selected.urgent" = {
        background-color = mkLiteral bright.red;
        text-color = mkLiteral primary.background;
      };
      mode-switcher = {
        border = mkLiteral "2px 0 0";
        border-color = mkLiteral normal.magenta;
      };
      "case-indicater, entry, prompt, button" = {
        spacing = 0;
        text-color = mkLiteral primary.foreground;
      };
      "button.selected" = {
        text-color = mkLiteral normal.green;
      };
      textbox-prompt-sep = {
        expand = false;
        str = ";";
        text-color = mkLiteral normal.magenta;
        margin = mkLiteral "0 0.3em 0 0";
      };
      "element-text, element-icon" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
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
    patchPhase = with colors "#"; ''
    for file in `find . -name '*.scss' -or -name '*.svg'` ; do
      substituteInPlace $file \
        --replace '#282828' '${primary.background}' \
        --replace '#ebdbb2' '${primary.foreground}' \
        --replace '#fbf1c7' '${primary.fg1}' \
        --replace '#3c3836' '${primary.bg1}' \
        --replace '#689d6a' '${normal.cyan}' \
        --replace '$primary_caret_color: #1d2021' '$primary_caret_color: ${primary.foreground}' \
        --replace '#1d2021' '${normal.black}' \
        --replace '#03a9f4' '${normal.blue}' \
        --replace '#ef6c00' '${normal.orange}' \
        --replace '#673ab7' '${normal.magenta}' \
        --replace '#f44336' '${normal.red}' \
        --replace '#4caf50' '${normal.green}' \
        --replace '#83a598' '${bright.blue}' ;
    done
    '';

    installPhase = ''
      mkdir -p $out/share/themes/${pname}
      cp -a . $out/share/themes/${pname}
    '';
  };
}
