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
      overlays = [ rust-overlay.overlays.default local-overlay ];
      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
      };
      home-config = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./colors.nix
            ./xsession.nix
            ./font.nix
            ./gui-apps.nix
            ./cli-apps.nix
            {
              home = {
                homeDirectory = "/home/jimbri01";
                username = "jimbri01";
                stateVersion = "22.11";
              };
              colors.theme = "corrosion";
              xsession.enable = true;
              systemd.user.startServices = true;
              home.keyboard = {
                layout = "us";
                variant = "dvp";
                options = [ "caps:escape" ];
              };
            }
          ];
        };
    in
    {
      defaultApp = pkgs.home-config;
      packages.default = pkgs.home-config;
    });
}
