{ config, lib, pkgs, ... }: {
  programs.foot = {
    enable = true;
    settings.csd.preferred = "none";
  };
  programs.zathura = {
    enable = true;
    options = {
      guioptions = "cs";
      adjust-open = "width";
      incremental-search = "false";
      recolor = "true";
      recolor-reverse-video = "false";
      statusbar-home-tilde = "true";
      selection-clipboard = "primary";
    };
  };
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-bin;
    profiles.default-release = {
      name = "default-release";
      userContent = let
        c = config.lib.stylix.colors;
      in ''
        @-moz-document url-prefix("about:reader")
        {
            body.dark
            {
                    color: #${c.base05} !important;
                    background-color: #${c.base00} !important;
            }
        }
      '';
    };
  };
  stylix.targets.firefox = {
    profileNames = ["default-release"];
    firefoxGnomeTheme.enable = true;
  };
  gtk.enable = true;
  gtk.gtk4.theme = config.gtk.theme;
  home.packages = with pkgs; [
    orca-slicer
    freecad-qt6
  ];
 }
