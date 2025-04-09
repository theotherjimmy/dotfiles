# flake.nix, the mothership of the dot-files. Take your seats, the show is
# about to start.
{
  description = "A bland config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/6313551cd05425cd5b3e63fe47dbc324eabb15e4";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";
    deploy.inputs.utils.follows = "flake-utils";

    devshell.url = "github:numtide/devshell/main";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
      self,
      nixpkgs,
      flake-utils,
      home-manager,
      rust-overlay,
      hyprland,
      deploy,
      devshell,
  }:
  let local-overlay = final: prior:
    prior.lib.filesystem.packagesFromDirectoryRecursive {
      callPackage = prior.callPackage;
      directory = ./pkgs;
    };
    mkComputer = hostName: includeUser: nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({...}: { nixpkgs.overlays = [ local-overlay ]; })
        ./computers/${hostName}/config.nix
        ./computers/${hostName}/hardware.nix
        home-manager.nixosModules.home-manager
        
      ] ++ nixpkgs.lib.optional (includeUser) ({...}: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.jimbri01 = import ./modules/top-level.nix;
        };
      });
    };
  in {
    nixosConfigurations.nixboi = mkComputer "nixboi" true;
    nixosConfigurations.tablet = mkComputer "tablet" true;
    deploy.nodes.tablet = {
      hostname = "tablet.local";
      profiles.system = {
        user = "root";
        path = deploy.lib.x86_64-linux.activate.nixos self.nixosConfigurations.tablet;
      };
    };
    deploy.nodes.nixboi = {
      hostname = "nixboi.local";
      profiles.system = {
        user = "root";
        path = deploy.lib.x86_64-linux.activate.nixos self.nixosConfigurations.nixboi;
      };
    };
  } // (flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [
        devshell.overlays.default
      ];
      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
      };
    in
    {
      devShell = pkgs.devshell.mkShell {
        motd = "";
        packages = [ pkgs.deploy-rs ];
        env = [{name = "NIX_PATH"; value = "nixpkgs=${nixpkgs}";}];
      };
    }));
}
