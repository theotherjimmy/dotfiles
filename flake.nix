# flake.nix, the mothership of the dot-files. Take your seats, the show is
# about to start.
{
  description = "A bland, gruvbox-dark config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    home-manager.url   = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, rust-overlay }:
    let
      overlays = [
        rust-overlay.overlay
        (final: super: { inherit (self.packages."${super.system}") autorandr-rs rpn-c; })
      ];
      system = "x86_64-linux";
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
            ./email.nix
          ];
          colors.theme = "nord-dark";
          nixpkgs.overlays = overlays;
          xsession.enable = true;
          systemd.user.startServices = true;
          home.keyboard = {
            layout = "us";
            variant = "dvp";
            options = ["caps:escape"];
          };
        };
      };
    in {
      packages.x86_64-linux.home-config = home-config.activationPackage;
      packages.x86_64-linux.autorandr-rs = pkgs.callPackage ./pkgs/autorandr-rs.nix {};
      packages.x86_64-linux.rpn-c = pkgs.callPackage ./pkgs/rpn-c.nix {};
      defaultApp.x86_64-linux = {
        type = "app";
        program = "${self.packages.x86_64-linux.home-config}/activate";
      };
    };
}
