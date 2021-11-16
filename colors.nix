{ config, lib, pkgs, ... }:

let
  colorthemes = {
    nord-dark = {
      base00 = "2e3440";
      base01 = "3b4252";
      base02 = "434c5e";
      base03 = "4c566a";
      base04 = "d8dee9";
      base05 = "e5e9f0";
      base06 = "eceff4";
      base07 = "8fbcbb";
      base08 = "88c0d0";
      base09 = "81a1c1";
      base0A = "5e81ac";
      base0B = "bf616a";
      base0C = "d08770";
      base0D = "ebcb8b";
      base0E = "a3be8c";
      base0F = "b48ead";
    };
    # from https://github.com/edunfelt/base16-rose-pine-scheme
    rose-pine = {
      base00 = "191724";
      base01 = "1f1d2e";
      base02 = "26233a";
      base03 = "555169";
      base04 = "6e6a86";
      base05 = "e0def4";
      base06 = "f0f0f3";
      base07 = "c5c3ce";
      base08 = "e2e1e7";
      base09 = "eb6f92";
      base0A = "f6c177";
      base0B = "ebbcba";
      base0C = "31748f";
      base0D = "9ccfd8";
      base0E = "c4a7e7";
      base0F = "e5e5e5";
    };
    rose-pine-moon = {
      base00 = "232136";
      base01 = "2a273f";
      base02 = "393552";
      base03 = "59546d";
      base04 = "817c9c";
      base05 = "e0def4";
      base06 = "f5f5f7";
      base07 = "d9d7e1";
      base08 = "ecebf0";
      base09 = "eb6f92";
      base0A = "f6c177";
      base0B = "ea9a97";
      base0C = "3e8fb0";
      base0D = "9ccfd8";
      base0E = "c4a7e7";
      base0F = "b9b9bc";
    };
    # from https://github.com/dawikur/base16-gruvbox-scheme
    gruvbox-dark = {
      base00 = "282828"; # ----
      base01 = "3c3836"; # ---
      base02 = "504945"; # --
      base03 = "665c54"; # -
      base04 = "bdae93"; # +
      base05 = "d5c4a1"; # ++
      base06 = "ebdbb2"; # +++
      base07 = "fbf1c7"; # ++++
      base08 = "fb4934"; # red
      base09 = "fe8019"; # orange
      base0A = "fabd2f"; # yellow
      base0B = "b8bb26"; # green
      base0C = "8ec07c"; # aqua/cyan
      base0D = "83a598"; # blue
      base0E = "d3869b"; # purple
      base0F = "d65d0e"; # brown
    };
    gruvbox-light = {
      base00 = "fbf1c7"; # ----
      base01 = "ebdbb2"; # ---
      base02 = "d5c4a1"; # --
      base03 = "bdae93"; # -
      base04 = "665c54"; # +
      base05 = "504945"; # ++
      base06 = "3c3836"; # +++
      base07 = "282828"; # ++++
      base08 = "9d0006"; # red
      base09 = "af3a03"; # orange
      base0A = "b57614"; # yellow
      base0B = "79740e"; # green
      base0C = "427b58"; # aqua/cyan
      base0D = "076678"; # blue
      base0E = "8f3f71"; # purple
      base0F = "d65d0e"; # brown
    };
    # form https://github.com/sainnhe/everforest
    everforest = {
      base00 = "2b3339";
      base01 = "323c41";
      base02 = "503946";
      base03 = "868d80";
      base04 = "d3c6aa";
      base05 = "d3c6aa";
      base06 = "e9e8d2";
      base07 = "fff9e8";
      base08 = "7fbbb3";
      base09 = "d699b6";
      base0A = "83c092";
      base0B = "dbbc7f";
      base0C = "e69875";
      base0D = "a7c080";
      base0E = "e67e80";
      base0F = "d699b6";
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
