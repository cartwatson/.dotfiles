{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
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

    selfhostblocks.url = "github:ibizaman/selfhostblocks";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-bleedingedge,
    sops-nix,
    nix-minecraft,
    selfhostblocks,
    ...
  }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";
      settings = import ./profiles/server-settings.nix;
      nixpkgsPatchedSHB = selfhostblocks.lib.${system}.patchedNixpkgs;
      hostsUsingSHB = [ "nova" ];
    in {
      # https://github.com/Electrostasy/dots/blob/0eb9d91d517d74b7f0891bff5992b17eb50f207c/flake.nix#L102-L121
      nixosConfigurations = lib.pipe ./hosts [
        builtins.readDir

        (lib.filterAttrs (name: _value: name != "hardware")) # don't try to build hw folder

        # Define the NixOS configurations
        (lib.mapAttrs (name: _value:
          # conditionally include SHB for servers only
          # attempting to avoid any issues with using the patched nixpkgs
          let
            usesSHB = builtins.elem name hostsUsingSHB;
            nixpkgsToUse = if usesSHB then nixpkgsPatchedSHB else nixpkgs.lib;
            shbModules = if usesSHB then [ selfhostblocks.nixosModules.default ] else [];
          in
          nixpkgsToUse.nixosSystem {
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
            ] ++ shbModules;
          }
        ))
      ];
    };
}
