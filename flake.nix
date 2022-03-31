# flake.nix, the mothership of the dot-files. Take your seats, the show is
# about to start.
{
  description = "A bland config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, rust-overlay }:
  flake-utils.lib.eachDefaultSystem (system:
    let
      local-overlay = final: super: {
        home-config = home-config.activationPackage;
        monitor-layout = final.callPackage ./pkgs/monitor-layout.nix { };
        rpn-c = final.callPackage ./pkgs/rpn-c.nix { };
        fre = final.callPackage ./pkgs/fre.nix { };
      };
      overlays = [ rust-overlay.overlay local-overlay ];
      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
      };
      home-config = home-manager.lib.homeManagerConfiguration {
        homeDirectory = "/home/jimbri01";
        username = "jimbri01";
        inherit system pkgs;
        configuration = { config, lib, pkgs, ... }: {
          imports = [
            ./colors.nix
            ./xsession.nix
            ./font.nix
            ./gui-apps.nix
            ./cli-apps.nix
          ];
          colors.theme = "rose-pine";
          nixpkgs.overlays = overlays;
          xsession.enable = true;
          systemd.user.startServices = true;
          home.keyboard = {
            layout = "us";
            variant = "dvp";
            options = [ "caps:escape" ];
          };
        };
      };
    in
    {
      defaultApp = {
        type = "app";
        program = "${pkgs.home-config}/activate";
      };
    });
}
