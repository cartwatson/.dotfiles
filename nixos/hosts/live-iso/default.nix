{ modulesPath, lib, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # allow legacy and UEFI booting
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  # SSH access for nixos-anywhere (install media only, not a real system)
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };
  users.users.root.initialHashedPassword = lib.mkForce "nixos";

  programs.bash.interactiveShellInit = ''
    echo ""
    echo "=== cartwatson's NixOS Install ISO ==="
    echo "  Connect ethernet and note your IP: $(hostname -I)"
    echo "  Then from your main machine run:"
    echo "    nix run github:nix-community/nixos-anywhere -- --flake .#<hostname> nixos@<this-ip>"
    echo ""
  '';
}
