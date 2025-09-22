{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-bleedingedge.url = "github:nixos/nixpkgs/master";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-minecraft = {
      url = "github:Infinidoge/nix-minecraft";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-bleedingedge, sops-nix, nix-minecraft, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      settings = import ./profiles/server-settings.nix;
    in {
      # https://github.com/Electrostasy/dots/blob/0eb9d91d517d74b7f0891bff5992b17eb50f207c/flake.nix#L102-L121
      nixosConfigurations = lib.pipe ./hosts [
        # List all the defined hosts.
        builtins.readDir

        # Filter specifically for directories in case there are single files (there aren't)
        (lib.filterAttrs (_name: value: value == "directory"))

        # Define the NixOS configurations
        (lib.mapAttrs (name: _value:
          lib.nixosSystem {
            specialArgs = {
              inherit settings;
              inherit nix-minecraft;
              pkgs-unstable = import nixpkgs-unstable {
                config.allowUnfree = true;
                inherit system;
              };
              pkgs-bleedingedge = import nixpkgs-bleedingedge {
                config.allowUnfree = true;
                inherit system;
              };
            };

            modules = [
              { networking.hostName = name; }
              sops-nix.nixosModules.sops

              ./hosts/${name}
              ./modules
              ./profiles
            ];
          }
        ))
      ];
    };
}
