{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;

      forEverySystem = lib.genAttrs lib.systems.flakeExposed;
      forEachSystem = lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
      # system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
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
            specialArgs = { inherit self; };

            modules = [
              { networking.hostName = name; }
              ./hosts/${name}
              # ./profiles/common
            ];
          }))
      ];
    };
}
