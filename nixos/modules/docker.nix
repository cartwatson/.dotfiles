{ pkgs, lib, ... }

{
  # install docker
  environment.systemPackages = (with pkgs; [
    docker
  ]);

  # settings for docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  users.extraGroups.docker.members = [ "cwatson" ];
}
