{ config, lib, pkgs, ... }:

let
  colors = config.colors.fn;
in {
  home.packages = [ pkgs.wezterm-nightly ];
  xdg.configFile."wezterm/wezterm.lua".text = let
    inherit (colors "#") primary normal bright;
  in ''
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
  programs.zathura = {
    enable = true;
    options = let inherit (colors "#") primary normal; in {
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
    terminal = "${pkgs.wezterm-nightly}/bin/wezterm";
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
      inherit (colors "#") primary normal bright;
    in {
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
      "case-indicator, entry, prompt, button" = {
        spacing = 0;
        text-color = mkLiteral primary.foreground;
      };
      "button.selected" = {
        text-color = mkLiteral normal.green;
      };
      inputbar = {
        spacing = 0;
        text-color = mkLiteral primary.foreground;
        padding = mkLiteral "2px";
        children = [ "prompt" "textbox-prompt-sep" "entry" "case-indicator" ];
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

    nativeBuildInputs = [
      pkgs.pkgconfig
      pkgs.sassc
      pkgs.optipng
      pkgs.librsvg
      pkgs.inkscape
      pkgs.gtk3
    ];

    propagatedUserEnvPkgs = [ pkgs.gtk-engine-murrine ];

    enableParallelBuilding = false;
    patchPhase = let inherit (colors "#") primary normal bright; in ''
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
