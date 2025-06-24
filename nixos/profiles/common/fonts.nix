{ pkgs, ... }:

{
  imports = [
  ];

  environment.systemPackages = (with pkgs; [
    miracode
  ]);
}
