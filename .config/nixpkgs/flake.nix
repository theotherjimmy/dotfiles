# flake.nix, the mothership of the dot-files. Take your seats, the show is
# about to start.
{
  description = "A bland, gruvbox-dark config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";

    home-manager.url   = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    emacs-overlay.url = "github:nix-community/emacs-overlay/master";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";

    nix-doom-emacs.url = "github:vlaci/nix-doom-emacs/master";
    nix-doom-emacs.inputs.nixpkgs.follows = "nixpkgs";
    nix-doom-emacs.inputs.emacs-overlay.follows = "emacs-overlay";
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, nix-doom-emacs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      home-config = home-manager.lib.homeManagerConfiguration {
        homeDirectory = "/home/jimbri01";
        username = "jimbri01";
        inherit system pkgs;
        configuration = { config, lib, pkgs, ... }: {
          imports = [
            nix-doom-emacs.hmModule
            ./colors.nix
            ./xsession.nix
            ./font.nix
            ./gui-apps.nix
            ./cli-apps.nix
          ];
          colors.theme = "gruvbox-dark";
          nixpkgs.overlays = [ emacs-overlay.overlay ];
          xsession.enable = true;
          systemd.user.startServices = true;
          home.keyboard = {
            layout = "us";
            variant = "dvp";
            options = ["caps:escape"];
          };
          home.stateVersion = "21.03";
        };
      };
    in {
      packages.x86_64-linux.home-config = home-config.activationPackage;
      defaultApp.x86_64-linux = {
        type = "app";
        program = "${self.packages.x86_64-linux.home-config}/activate";
      };
    };
}
