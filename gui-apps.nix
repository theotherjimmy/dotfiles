{ config, lib, pkgs, ... }:

let
  c = config.colors.fn "#";
in {
  home.packages = [ pkgs.wezterm-nightly ];
  xdg.configFile."wezterm/wezterm.lua".text = 
    ''
      local wezterm = require 'wezterm';
      return {
        colors = {
          foreground = "${c.base05}",
          background = "${c.base00}",
          cursor_bg = "${c.base05}",
          cursor_border = "${c.base03}",
          cursor_fg = "${c.base00}",
          selection_bg = "${c.base05}",
          selection_fg = "${c.base00}",
          ansi = {
            "${c.base00}", "${c.base08}", "${c.base0B}", "${c.base0A}",
            "${c.base0D}", "${c.base0E}", "${c.base0C}", "${c.base05}"
          },
          brights = {
            "${c.base03}", "${c.base09}", "${c.base0B}", "${c.base0A}",
            "${c.base04}", "${c.base06}", "${c.base0F}", "${c.base07}"
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
    options = {
      font = config.font.emstr;
      guioptions = "cs";
      adjust-open = "width";
      incremental-search = "false";
      recolor = "true";
      recolor-reverse-video = "false";
      statusbar-home-tilde = "true";
      selection-clipboard = "primary";

      default-bg = c.base00;
      default-fg = c.base01;
      statusbar-fg = c.base04;
      statusbar-bg = c.base02;
      inputbar-bg = c.base00;
      inputbar-fg = c.base07;
      notification-bg = c.base00;
      notification-fg = c.base07;
      notification-error-bg = c.base00;
      notification-error-fg = c.base08;
      notification-warning-bg = c.base00;
      notification-warning-fg = c.base08;
      completion-bg = c.base01;
      completion-fg = c.base0D;
      completion-highlight-fg = c.base07;
      completion-highlight-bg = c.base0D;
      recolor-lightcolor = c.base00;
      recolor-darkcolor = c.base06;
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
    in {
      "*" = {
        background-color = mkLiteral c.base00;
        border-color = c.base0E;
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
        text-color = mkLiteral c.base05;
      };
      listview = {
        border = mkLiteral "2px solid 0 0";
        padding = mkLiteral "2px 0 0";
        border-color = mkLiteral c.base0E;
        spacing = mkLiteral "2px";
        scrollbar = mkLiteral c.base0E;
        lines = 20;
      };
      element = {
        border = 0;
        padding = mkLiteral "2px";
      };

      "element.normal.normal" = {
        text-color = mkLiteral c.base05;
      };
      "element.alternate.normal" = {
        text-color = mkLiteral c.base05;
      };
      "element.selected.normal" = {
        background-color = mkLiteral c.base01;
        text-color = mkLiteral c.base0B;
      };

      "element.normal.active" = {
        background-color = mkLiteral c.base0A;
        text-color = mkLiteral c.base00;
      };
      "element.alternate.active" = {
        background-color = mkLiteral c.base0A;
        text-color = mkLiteral c.base00;
      };
      "element.selected.active" = {
        background-color = mkLiteral c.base0A;
        text-color = mkLiteral c.base01;
      };

      "element.normal.urgent" = {
        background-color = mkLiteral c.base08;
        text-color = mkLiteral c.base00;
      };
      "element.alternate.urgent" = {
        background-color = mkLiteral c.base08;
        text-color = mkLiteral c.base00;
      };
      "element.selected.urgent" = {
        background-color = mkLiteral c.base08;
        text-color = mkLiteral c.base01;
      };
      mode-switcher = {
        border = mkLiteral "2px 0 0";
        border-color = mkLiteral c.base0E;
      };
      "case-indicator, entry, prompt, button" = {
        spacing = 0;
        text-color = mkLiteral c.base05;
      };
      "button.selected" = {
        text-color = mkLiteral c.base0B;
      };
      inputbar = {
        spacing = 0;
        text-color = mkLiteral c.base05;
        padding = mkLiteral "2px";
        children = [ "prompt" "textbox-prompt-sep" "entry" "case-indicator" ];
      };
      textbox-prompt-sep = {
        expand = false;
        str = ";";
        text-color = mkLiteral c.base0E;
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
    patchPhase = ''
    for file in `find . -name '*.scss' -or -name '*.svg'` ; do
      substituteInPlace $file \
        --replace '#282828' '${c.base00}' \
        --replace '#ebdbb2' '${c.base05}' \
        --replace '#fbf1c7' '${c.base07}' \
        --replace '#3c3836' '${c.base03}' \
        --replace '#689d6a' '${c.base0C}' \
        --replace '$primary_caret_color: #1d2021' '$primary_caret_color: ${c.base05}' \
        --replace '#1d2021' '${c.base03}' \
        --replace '#03a9f4' '${c.base0D}' \
        --replace '#ef6c00' '${c.base0A}' \
        --replace '#673ab7' '${c.base0E}' \
        --replace '#f44336' '${c.base08}' \
        --replace '#4caf50' '${c.base0B}' \
        --replace '#83a598' '${c.base04}' ;
    done
    '';

    installPhase = ''
      mkdir -p $out/share/themes/${pname}
      cp -a . $out/share/themes/${pname}
    '';
  };
}
