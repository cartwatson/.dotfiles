{ config, lib, pkgs, pkgs-unstable, ... }:

let
  baseCfg = config.pillar.services;
  cfg = baseCfg.helix;
  lspPackages = import ./lsp-packages.nix { inherit pkgs; };
in
{
  options.pillar.services.helix = {
    enable = lib.mkEnableOption "Enable Helix and LSPs.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs-unstable; [
      helix
    ]) ++ (with pkgs; [
      gh
    ]) ++ lspPackages;
  };
}
