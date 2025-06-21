{ config, lib, pkgs, ... }:

let
  orcaslicer-version = "2.3.0";
  orcaslicer-src = pkgs.fetchurl rec {
    version = orcaslicer-version;
    url = "https://github.com/SoftFever/OrcaSlicer/releases/download/v${version}/OrcaSlicer_Linux_AppImage_Ubuntu2404_V${version}.AppImage";
    hash = "sha256-E+QL8nTwAS6DIlOfwIw2fIboPm3jrCBJaNoOMmNLMnA=";
  };
  orcaslicer = pkgs.appimageTools.wrapType2 {
    pname = "orcaSlicer";
    version = orcaslicer-version;
    src = orcaslicer-src;
    extraPkgs = (pkgs: with pkgs; [ webkitgtk_4_1 ]);
  };
  c = config.colors.fn "#";
in
{
  home.packages = [
    orcaslicer
    pkgs.freecad-wayland
    pkgs.wezterm
    pkgs.freetube
    pkgs.gamescope
    pkgs.r2modman
    pkgs.protontricks
    (pkgs.steam.override {
      extraProfile = ''
        unset VK_ICD_FILENAMES
        export VK_ICD_FILENAMES=`realpath /run/opengl-driver/share`/vulkan/icd.d/radeon_icd.x86_64.json:`realpath /run/opengl-driver-32/share`/vulkan/icd.d/radeon_icd.i686.json'';
    })
  ];
  programs.foot = {
    enable = true;
    settings.main = {
      font = "${config.font.name}NerdFontMono:size=${toString config.font.em}";
      dpi-aware = "yes";
    };
    settings.colors = let c = config.colors.fn ""; in {
      foreground = c.base05;
      background = c.base00;
      regular0 = c.base00;
      regular1 = c.base08;
      regular2 = c.base0B;
      regular3 = c.base0A;
      regular4 = c.base0D;
      regular5 = c.base0E;
      regular6 = c.base0C;
      regular7 = c.base05;
      bright0 = c.base03;
      bright1 = c.base09;
      bright2 = c.base0B;
      bright3 = c.base0A;
      bright4 = c.base04;
      bright5 = c.base06;
      bright6 = c.base0F;
      bright7 = c.base07;
    };
  };
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
    package = pkgs.firefox-bin;
  };
  gtk.enable = true;
  gtk.iconTheme.name = "Adwaita";
  gtk.iconTheme.package = pkgs.adwaita-icon-theme;
  gtk.theme.name = "gruvbox-gtk";
  gtk.theme.package = pkgs.stdenv.mkDerivation rec {
    pname = "gruvbox-gtk";
    version = "master";

    src = pkgs.fetchFromGitHub {
      owner = "3ximus";
      repo = pname;
      rev = "fda45c127bd5ed3cdd2dfcc6c396e7aef99abd8e";
      sha256 = "1vlgsp7hgf96bzlj54rimmimzhpchh3z3a4fll71wxghr3gpv27d";
    };

    nativeBuildInputs = [
      pkgs.pkg-config
      pkgs.sassc
      pkgs.optipng
      pkgs.librsvg
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
