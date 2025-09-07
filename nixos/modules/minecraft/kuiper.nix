{ pkgs }:

{
  kuiper = {
    enable = true;
    package = pkgs.fabricServers.fabric-1_21_8;
    enableReload = true;

    serverProperties = {
      server-port = 5003;
      max-players = 20;
      white-list = true;
      enable-query = true;
      sync-chunk-writes = false;
      difficulty = "hard";
      gamemode = "survival";
      motd = "§9Kuiper§r: Hosted by garamond";
    };

    whitelist = {
      # `curl -s "https://api.mojang.com/users/profiles/minecraft/<USERNAME>" | jq -r '.id'`
      garamond = "fde452b2-e48c-4f3d-bc5c-eca2ecbbe55d";
      TheFreakBob = "39b7674e-445f-4f76-82b5-ef8c8f925f53";
      awashingmachine = "bf80d49b-8791-4c16-962b-901bf7bc38d6";
      "1Tbspflour" = "a307eb1e-96ae-4d47-b283-15c4790831ea";
      millieerocks = "d2a18880-ba00-4d49-8fa9-d13e43f13e3d";
      runclubfein = "da856c15-0e9a-4bcb-854f-4a069e426c27";
      SweenyBandwagon = "1563cb25-01a8-4b21-997e-a31a58cac838";
      CozyCrafts24 = "411c9e58-fbe4-4092-9b92-ef55bffd31da";
      Gagecarling = "af0b0012-4ad1-4598-8887-b69443c4865d";
    };

    symlinks = {
      mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
        # CDN: find link to specific file, and `copy link` from the download button
        # SHA512: `nix-prefetch-url --type sha512 --name <NAME> "<URL>"`
        Fabric-API = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/Q8ssLFZp/fabric-api-0.133.0%2B1.21.8.jar";
          sha512 = "1pw4y3lii84c9nll9cl9pgcd8qrlg7bppj791anwqd84b1sq5w6z65vqbpxlx4brakjww9i2n5il7lj509nsrv30yharwqfk392paq4";
        };
        lithium = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/pDfTqezk/lithium-fabric-0.18.0%2Bmc1.21.8.jar";
          sha512 = "07i11gq0yhdmv19ky4gp4181c7c5089ac110acpx1jbcq6kvisviw16vzgpl3a7d8mh16zdnlxg16mm548fcwaq1j7zi3plc03rasbc";
        };
      });

      # ICON: /meta/server-icon.png
      # "server-icon.png" = icon + "/meta/server-icon.png";
      # RCON_CMDS_STARTUP: gamerule playersSleepingPercentage 1
    };
  };
}

