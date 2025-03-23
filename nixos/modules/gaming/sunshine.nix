{ config, pkgs, inputs, ... }:

{
  imports =
    [
    ];

  environment.systemPackages = (with pkgs; [
    sunshine
  ]);

  services.sunshine = {
    enable = true;
    openFirewall = true;
    applications.apps = [
      steam
      prismlauncher
    ];
  };
}
