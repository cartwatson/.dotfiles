{ pkgs, unstable, lib, ... }:

{
  environment.systemPackages = with unstable; [
    helix
  ];

  environment.systemPackages = (with pkgs; [
    # LSPs for helix
    marksman
    unstable.bash-language-server
    python312Packages.python-lsp-server
  ]);
}
