{ config, lib, pkgs, ... }:

let
  colorthemes = {
    nord-dark = {
      primary = {
        background = "2e3440";
        foreground = "d8dee9";
        bg-soft = "3b4252";
        bg1 = "3b4252";
        bg2 = "434e5e";
        bg3 = "4c566a";
        bg4 = "4c566a";
        fg1 = "e5e9f0";
        fg2 = "e5e9f0";
        fg3 = "eceff4";
        fg4 = "eceff4";
      };
      normal = {
        black = "3b4252";
        red = "bf616a";
        green = "a3be8c";
        yellow = "ebcb8b";
        blue = "81a1c1";
        magenta = "b48ead";
        cyan = "88c0d0";
        orange = "d08770";
        white = "e5e9f0";
      };
      bright = {
        black = "373e4d";
        red = "94545d";
        green = "809575";
        yellow = "b29e75";
        blue = "68809a";
        magenta = "8c738c";
        cyan = "6d96a5";
        orange = "d08770";
        white = "aeb3bb";
      };
    };
    gruvbox-dark = {
      primary = {
        background = "282828";
        foreground = "ebdbb2";
        bg-soft = "32302f";
        bg1 = "3c3836";
        bg2 = "504945";
        bg3 = "665c54";
        bg4 = "7c6f64";
        fg1 = "ebdbb2";
        fg2 = "d5c4a1";
        fg3 = "bdae93";
        fg4 = "a89984";
      };
      normal = {
        black = "282828";
        red = "cc241d";
        green = "98971a";
        yellow = "d79921";
        blue = "458588";
        magenta = "b16286";
        cyan = "689d6a";
        orange = "d65d0e";
        white = "7c6f64";
      };
      bright = {
        black = "928374";
        red = "fb4934";
        green = "b8bb26";
        yellow = "fabd2f";
        blue = "83a598";
        magenta = "d3869b";
        cyan = "8ec07c";
        orange = "fe8019";
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
  options.colors = let inherit (lib) types mkOption; in {
    theme = mkOption { type = types.enum (builtins.attrNames colorthemes); };
    fn = mkOption { };
  };
  config.colors.fn = pre: let
    to-map = _path: value: "${pre}${value}";
    input = colorthemes."${config.colors.theme}";
  in lib.attrsets.mapAttrsRecursive to-map input;
}
