{ pkgs }:

let
  port = 5003;
in
{
  kuiper = {
    enable = true;
    package = pkgs.fabricServers.fabric-26_3.override { jre_headless = pkgs.openjdk25_headless; };

    serverProperties = {
      server-port = port;
      max-players = 10;
      white-list = true;
      enable-query = true;
      sync-chunk-writes = false;
      difficulty = "hard";
      gamemode = "survival";
      # motd = "§9Kuiper§r: Hosted by garamond";
      motd = "\\u00A79Kuiper\\u00A7r: Hosted by garamond";
    };

    jvmOpts = "-Xms2G -Xmx4G";

    # To add to whitelist, run the below
    # `curl -s "https://api.mojang.com/users/profiles/minecraft/USERNAME" | jq -r '.id'`
    whitelist = {
      "garamond" = "fde452b2-e48c-4f3d-bc5c-eca2ecbbe55d";
      "TheFreakBob" = "39b7674e-445f-4f76-82b5-ef8c8f925f53";
      "awashingmachine" = "bf80d49b-8791-4c16-962b-901bf7bc38d6";
      "1Tbspflour" = "a307eb1e-96ae-4d47-b283-15c4790831ea";
      "millieerocks" = "d2a18880-ba00-4d49-8fa9-d13e43f13e3d";
      "runclubfein" = "da856c15-0e9a-4bcb-854f-4a069e426c27";
      "SweenyBandwagon" = "1563cb25-01a8-4b21-997e-a31a58cac838";
      "CozyCrafts24" = "411c9e58-fbe4-4092-9b92-ef55bffd31da";
      "Gagecarling" = "af0b0012-4ad1-4598-8887-b69443c4865d";
      "cmcaguilera" = "24504e8e-9216-4861-9d73-db90a16dffca";
    };

    symlinks = {
      mods = pkgs.linkFarmFromDrvs "mods" (builtins.attrValues {
        # CDN: find link to specific file, and `copy link` from the download button
        # SHA512: `nix-prefetch-url --type sha512 --name <NAME> "<URL>"`
        FerriteCore = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/uXXizFIs/versions/d5ddUdiB/ferritecore-9.0.0-fabric.jar?mr_download_reason=standalone&mr_game_version=26.3&mr_loader=fabric";
          sha512 = "22fbjz59a2qh4bynn6rmplbawi36wgddycwsqvz1x5f11l5355khay5m6kf8xx1bzjcx4vivl1pc00xhcrz9hl95za1jk3q25zaj7yq";
        };
        Fabric-API = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/bNnaTiuM/fabric-api-0.161.0%2B26.3.jar?mr_download_reason=standalone&mr_game_version=26.3&mr_loader=fabric";
          sha512 = "2fi1nhjdv0rr194ln31msvdd8413a1hipwkj7xmrrvdasp17qbrkqjyrql7wpnqpza98vz44rqbd68yqlksbxbjhkg1zqgxss32aszd";
        };
        lithium = pkgs.fetchurl {
          url = "https://cdn.modrinth.com/data/gvQqBUqZ/versions/WXHRsMRl/lithium-fabric-0.26.1%2Bmc26.3.jar?mr_download_reason=standalone&mr_game_version=26.3&mr_loader=fabric";
          sha512 = "1crqr1z83p23r0a1i46di0sw1qbpg8dbf9hj53ys9vhv3rgnpn029cscccvj4lah1j7dljspd53h6b0hvcz22x20dg00gr0g81rpfxc";
        };
      });

      # RCON_CMDS_STARTUP: gamerule playersSleepingPercentage 1
    };
  };
}

