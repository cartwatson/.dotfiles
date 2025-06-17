{ pkgs-unstable, ... }:

{
  imports =
    [
    ];

  environment.systemPackages = (with pkgs-unstable; [
    sunshine
  ]);

  services.sunshine = {
    # start service by running `sunshine` in terminal
    enable = false;
    autoStart = false;
    capSysAdmin = true;
    openFirewall = true;
  };

  networking.firewall = {
    enable = true;
    # mystery process on 48010, disabled
    allowedTCPPorts = [ 47984 47989 47990 ];
    allowedUDPPortRanges = [
      { from = 47998; to = 48000; }
      { from = 8000; to = 8010; }
    ];
  };
}
