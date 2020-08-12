{ config, lib, pkgs, ... }:

let
  colorthemes = {
    gruvbox-dark = {
      primary = {
        background = "282828";
        foreground = "ebdbb2";
        bg-soft = "32302f";
      };
      normal = {
        black = "282828";
        red = "cc241d";
        green = "98971a";
        yellow = "d79921";
        blue = "458588";
        magenta = "b16286";
        cyan = "d65d0e";
        white = "7c6f64";
      };
      bright = {
        black = "928374";
        red = "fb4934";
        green = "b8bb26";
        yellow = "fabd2f";
        blue = "83a598";
        magenta = "d3869b";
        cyan = "fe8019";
        white = "ebdbb2";
      };
    };
    gruvbox-light = {
      primary = {
        background = "fbf1c7";
        foreground = "3c3836";
        bg-soft = "f2e5bc";
      };
      normal = {
        black = "fbf1c7";
        red = "cc241d";
        green = "98971a";
        yellow = "d79921";
        blue = "458588";
        magenta = "b16286";
        cyan = "d65d0e";
        white = "7c6f64";
      };
      bright = {
        black = "928374";
        red = "9d0006";
        green = "79740e";
        yellow = "b57614";
        blue = "076678";
        magenta = "8f3f71";
        cyan = "af3a03";
        white = "3c3836";
      };
    };
  };
in {
  options.colors = with lib; {
    theme = mkOption { type = types.enum (builtins.attrNames colorthemes); };
    fn = mkOption { };
  };
  config.colors.fn = pre: let
    to-map = _path: value: "${pre}${value}";
    input = colorthemes."${config.colors.theme}";
  in lib.attrsets.mapAttrsRecursive to-map input;
}
