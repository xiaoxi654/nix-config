{ config, lib, pkgs, ... }:

let
  draslToml = lib.importTOML ./configs/drasl.toml;

  # Maps each OIDC provider name to its sops-encrypted client secret.
  oidcClientSecretNames = {
    "oauth.dn42" = "drasl_oidc_client_secret_iedon";
    "kioubit.auth" = "drasl_oidc_client_secret_kioubit";
  };
in
{
  sops.secrets.drasl_oidc_client_secret_iedon = { };
  sops.secrets.drasl_oidc_client_secret_kioubit = { };

  services.drasl = {
    enable = true;
    settings = draslToml // {
      RegistrationOIDC = map (provider: provider // {
        ClientSecretFile = config.sops.secrets.${oidcClientSecretNames.${provider.Name}}.path;
      }) draslToml.RegistrationOIDC;
    };
  };
}
