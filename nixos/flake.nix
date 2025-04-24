{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
    in {
      # https://github.com/Electrostasy/dots/blob/0eb9d91d517d74b7f0891bff5992b17eb50f207c/flake.nix#L102-L121
      nixosConfigurations = lib.pipe ./hosts [
        # List all the defined hosts.
        builtins.readDir

        # Filter specifically for directories in case there are single files (there aren't)
        (lib.filterAttrs (name: value: value == "directory"))

        # Define the NixOS configurations
        (lib.mapAttrs (name: value:
          lib.nixosSystem {
            specialArgs = {
              pkgs-unstable = import nixpkgs-unstable {
                config.allowUnfree = true;
                inherit system;
              };
            };

            modules = [
              { networking.hostName = name; }
              ./hosts/${name}
              ./profiles/common/default.nix
            ];
          }
        ))
      ];
    };
}
