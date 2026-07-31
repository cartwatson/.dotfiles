{ self, modulesPath, lib, pkgs, ... }:

{
  imports = [
    # TODO: change to gnome installer
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  programs.bash.interactiveShellInit = ''
    ${builtins.readFile ../../../bashrc.sh}
    ${builtins.readFile ../../../aliases.sh}
    alias cdd="clear; cd /etc/dotfiles"
  '';

  # Bundle the flake source into the ISO at /etc/dotfiles
  environment.etc."dotfiles".source = self;

  # available at `ssh nixos@live-iso.local`
  services.openssh.enable = true;
  users.users.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AHHH... your-public-key" # TODO: put real things here
  ];

  environment.systemPackages = (with pkgs; [
    disko
    parted
  ]);
}
