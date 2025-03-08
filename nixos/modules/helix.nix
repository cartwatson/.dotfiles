{ config, pkgs, lib, ... }:

{
  environment.systemPackages = (with pkgs; [
    helix
    # LSPs for helix
    marksman
    bash-language-server
    python312Packages.python-lsp-server
  ]);
}
