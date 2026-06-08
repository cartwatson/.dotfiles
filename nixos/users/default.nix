{ ... }:

{
  imports = [
    ./cwatson.nix
    ./wwatson.nix
    ./jgordon.nix
  ];

  users.enforceIdUniqueness = true;
}

