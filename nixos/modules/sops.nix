{ ... }:

{
  # NOTE: always enabled

  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";

    age = {
      keyFile = "/home/cwatson/.config/sops/age/keys.txt";
      generateKey = true;
    };
  };
}

