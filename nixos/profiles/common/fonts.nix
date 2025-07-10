{ pkgs, ... }:

{
  imports = [
  ];

  environment.systemPackages = (with pkgs; [
    open-sans       # primary font

    miracode        # primary monospace
    jetbrains-mono  # backup monospace
  ]);
}
