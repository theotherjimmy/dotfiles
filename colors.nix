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
    #Rusty background with Coppery and Orange foreground
    # Rose Pine Moon rotated by 135 Degrees
    corrosion = {
      base00 = "29221d";
      base01 = "302923";
      base02 = "403730";
      base03 = "5e5650";
      base04 = "8d7d70";
      base05 = "f5dccb";
      base06 = "f7f5f4";
      base07 = "e2d6cd";
      base08 = "f0ebe7";
      base09 = "49aa5c";
      base0A = "64dcd8";
      base0B = "65c196";
      base0C = "ef456e";
      base0D = "e0bdcc";
      base0E = "d6ad66";
      base0F = "bdb8b6";
    };
    # Purple and cyan w/ green-grey bg
    # Rose Pine Moon rotated by 270 Degrees
    glow-tulip = {
      base00 = "1e2524";
      base01 = "232c2a";
      base02 = "313b39";
      base03 = "515958";
      base04 = "728381";
      base05 = "8ef1e5";
      base06 = "eff7f5";
      base07 = "c2dedb";
      base08 = "dbf0ee";
      base09 = "928ee6";
      base0A = "f5b8e2";
      base0B = "c3a1e6";
      base0C = "38975b";
      base0D = "a9d295";
      base0E = "6cc1c2";
      base0F = "b6bab9";
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
