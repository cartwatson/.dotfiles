{ config, lib, pkgs, pkgs-unstable, ... }:

let
  baseCfg = config.custom.services;
  cfg = baseCfg.helix;
  lspPackages = import ./lsp-packages.nix { inherit pkgs; };
in
{
  options.custom.services.helix = {
    enable = lib.mkEnableOption "Enable Helix and LSPs.";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs-unstable; [
      helix
    ]) ++ lspPackages;
  };
}
