{ config, lib, pkgs, ... }:

let
  draslToml = lib.importTOML ./configs/drasl.toml;
in
{
    sops.secrets.drasl_oidc_client_secret = { };

    services.drasl = {
      enable = true;
      settings = draslToml // {
        RegistrationOIDC = map (provider: provider // {
          ClientSecretFile = config.sops.secrets.drasl_oidc_client_secret.path;
        }) draslToml.RegistrationOIDC;
      };
    };
}
