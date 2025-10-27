# flake.nix, the mothership of the dot-files. Take your seats, the show is
# about to start.
{
  description = "A bland config";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";

    home-manager.url = "github:rycee/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

    deploy.url = "github:serokell/deploy-rs";
    deploy.inputs.nixpkgs.follows = "nixpkgs";
    deploy.inputs.utils.follows = "flake-utils";

    devshell.url = "github:numtide/devshell/main";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.inputs.flake-utils.follows = "flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , home-manager
    , rust-overlay
    , deploy
    , devshell
    , nixgl
    }:
    let
      local-overlay = final: prior:
        prior.lib.filesystem.packagesFromDirectoryRecursive {
          callPackage = prior.callPackage;
          directory = ./pkgs;
        };
      mkComputer = hostName: includeUser: {
        nixosConfigurations.${hostName} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ({ ... }: { nixpkgs.overlays = [ local-overlay ]; })
            ./computers/${hostName}/config.nix
            ./computers/${hostName}/hardware.nix
            home-manager.nixosModules.home-manager
            ./computers/common.nix
          ] ++ nixpkgs.lib.optional (includeUser) ({ ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.jimbri01 = import ./modules/top-level.nix;
            };
          });
        };
        deploy.nodes.${hostName} = {
          hostname = hostName;
          profiles.system = {
            user = "root";
            path = deploy.lib.x86_64-linux.activate.nixos
              self.nixosConfigurations.${hostName};
          };
        };
      };
    in
    (nixpkgs.lib.foldr nixpkgs.lib.recursiveUpdate { }
      [
        (mkComputer "nixboi" true)
        (mkComputer "tablet" true)
        (mkComputer "eycho" false)
      ])
    // (flake-utils.lib.eachDefaultSystem (system:
    let
      overlays = [
        devshell.overlays.default
        local-overlay
        nixgl.overlay
      ];
      pkgs = import nixpkgs {
        inherit system;
        inherit overlays;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      devShell = pkgs.devshell.mkShell {
        motd = "";
        packages = [ pkgs.deploy-rs ];
        env = [{ name = "NIX_PATH"; value = "nixpkgs=${nixpkgs}"; }];
      };
      formatter = pkgs.nixpkgs-fmt;
      packages.homeConfigurations."jimbri01" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./modules/top-level.nix
          {
            home.packages = [ pkgs.nixgl.nixGLIntel ];
            home.entertainment = false;
            home.sessionVariables.GBM_BACKENDS_PATH = "${pkgs.mesa}/lib/gbm";
          }
        ];
      };
    }));
}
