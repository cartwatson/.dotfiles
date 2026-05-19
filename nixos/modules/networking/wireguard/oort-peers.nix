{ settings }:
{
  nova = {
    publicKey = "v9SC8kS4wAJfjkFUOdHH25skpVb0XuAfkUnrMojt0lo=";
    address = "10.0.0.1";
    endpoint = "${settings.domainName}:51820";
  };
  jupiter = {
    publicKey = "Jgfg1lSaKlcTGN5GZzReV8VE24IFMFHS7M2SIkKCTVg=";
    address = "10.0.0.2";
  };
  eclipse = {
    publicKey = "ML4ge7d4dYxedhG0sxGg2JzftWoj/Sv0vw7K9TSac08=";
    address = "10.0.0.3";
  };
  # orion = {
  #   publicKey = "";
  #   address = "10.0.0.4";
  # };
  saturn = {
    publicKey = "FhMwNhmVeDN3RwLTdcEp5TweLzOTBaTHSaPYWXIdTnY=";
    address = "10.0.0.5";
  };
}
