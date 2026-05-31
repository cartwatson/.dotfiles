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

    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-bleedingedge, sops-nix, nix-minecraft, ... }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; };
    in {
      # https://github.com/Electrostasy/dots/blob/0eb9d91d517d74b7f0891bff5992b17eb50f207c/flake.nix#L102-L121
      nixosConfigurations = lib.pipe ./hosts [
        builtins.readDir

        # Define the NixOS configurations
        (lib.mapAttrs (name: _value:
          lib.nixosSystem {
            specialArgs = {
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

              ./hardware
              ./hosts/${name}
              ./modules
              ./profiles
              ./users
            ];
          }
        ))
      ];

      # export modules for others to pull in
      nixosModules = {
        desktop = {
          imports = [
            ./modules/desktop
            ./modules/editors/helix.nix
            ./modules/networking/tailscale.nix
            ./modules/services/timezone.nix
            ./profiles/common/base.nix
            ./profiles/desktop.nix
          ];
        };
        laptop = {
          imports = [
            ./modules/services/timezone.nix
            ./profiles/laptop.nix
          ];
        };
      };

      # export package lists for non-NixOS consumers (e.g. buildEnv)
      lib.lspPackages = import ./modules/editors/lsp-packages.nix;

      devShells.${system}= {
        network-debug = pkgs.mkShell {
          packages = with pkgs; [
            busybox # contains: telnet, traceroute
            dig
            nmap
            tcpdump
            unixtools.arp
          ];

          shellHook = ''
            # hype myself up so I actually want to fix things
            echo "YUH NETWORKING TIME LFG"
          '';
        };
      };
    };
}
