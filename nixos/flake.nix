{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, unstable, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      forEverySystem = lib.genAttrs lib.systems.flakeExposed;
      forEachSystem = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];

      # Create pkgs instances for each system
      pkgsForSystem = system: {
        pkgs = mkPkgs nixpkgs system;
        unstable = mkPkgs nixpkgs-unstable system;
      };

    in {

      # https://github.com/Electrostasy/dots/blob/0eb9d91d517d74b7f0891bff5992b17eb50f207c/flake.nix#L102-L121
      nixosConfigurations = lib.pipe ./hosts [
        # List all the defined hosts.
        builtins.readDir

        # Filter specifically for directories in case there are single files.
        (lib.filterAttrs (name: value: value == "directory"))

        # Define the NixOS configurations.
        (lib.mapAttrs (name: value:
          lib.nixosSystem {
            # Inject this flake into the module system.
            specialArgs = {
              inherit self;
              pkgsFor = pkgsForSystem;
            };

            modules = [
              { networking.hostName = name; }
              ./hosts/${name}
              ./profiles/common
            ];
          }
        ))
      ];
    };
}
