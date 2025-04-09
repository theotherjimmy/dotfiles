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
  {
    nixosConfigurations.nixboi = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nixboi-config.nix
        ./nixboi-hardware.nix
        home-manager.nixosModules.home-manager
        ({...}: {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jimbri01 = import ./modules/top-level.nix;
          };
        })
      ];
    };
    nixosConfigurations.tablet = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./tablet-hardware.nix
        home-manager.nixosModules.home-manager
        ({...}: {
          networking.hostName = "tablet";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.jimbri01 = import ./modules/top-level.nix;
          };
        })
      ];
    };
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
