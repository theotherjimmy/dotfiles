{ config, lib, pkgs, ... }:

let
  c = config.colors.fn "#";
in
{
  home.packages = [
    pkgs.wezterm
  ];
  programs.foot = {
    enable = true;
    settings.main = {
      font = "${config.font.font-conf-name}:size=${toString config.font.em}";
      dpi-aware = "yes";
      line-height = config.font.line-height;
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
    settings.csd.preferred = "none";
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
}
