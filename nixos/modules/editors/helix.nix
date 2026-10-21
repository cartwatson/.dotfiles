{ config, lib, pkgs, ... }:

let
  cfg = config.pillar.services.helix;
  lspPackages = import ./lsp-packages.nix { inherit pkgs; };
in
{
  options.pillar.services.helix = {
    enable = lib.mkEnableOption "Enable Helix and LSPs.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [
      helix
    ]) ++ (with pkgs; [
      gh
    ]) ++ lspPackages;
  };
}
