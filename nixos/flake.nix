{
  description = "NixOS config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-bleedingedge.url = "github:nixos/nixpkgs/master";

    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    defcon-wifi.url = "github:NixVegas/dcwifi/dc34";
    defcon-wifi.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-bleedingedge,
    nixos-hardware,
    disko,
    defcon-wifi,
    sops-nix,
    nix-minecraft,
    ...
  }:
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
              inherit self;
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
              disko.nixosModules.disko
              sops-nix.nixosModules.sops

              ./hardware
              ./hosts/${name}
              ./modules
              ./profiles
              ./users
            # TODO: find a better way here, because this is way too ugly (and WACK)
            ] ++ (lib.lists.optionals (name == "mercury" || name == "artemis") [
              defcon-wifi.nixosModules.default
              nixos-hardware.nixosModules.lenovo-thinkpad-t480s
            ]);
          }
        ))
      ];

      # export modules for others to pull in
      nixosModules = {
        desktop = {
          imports = [
            ./modules/desktop
            ./modules/editors/tmux.nix
            ./modules/editors/helix.nix
            ./modules/networking/tailscale.nix
            ./profiles/common/base.nix
            ./profiles/desktop.nix
          ];
        };
        laptop = {
          imports = [
            ./profiles/laptop.nix
          ];
        };
      };

      # export package lists for non-NixOS consumers (e.g. buildEnv)
      lib.lspPackages = import ./modules/editors/lsp-packages.nix;

      devShells.${system} = {
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
