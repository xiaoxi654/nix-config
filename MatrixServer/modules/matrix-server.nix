{config, lib, pkgs, ...}:

{
  sops.secrets.matrix_registration_token = {
    owner = "tuwunel";
    group = "tuwunel";
    mode = "0400";
  };

  services = {
    matrix-tuwunel = {
      enable = true;
      # package = pkgs.matrix-tuwunel.overrideAttrs { buildType = "debug"; };
      settings = {
        global = {
          allow_registration = true;
          registration_token_file = config.sops.secrets.matrix_registration_token.path;
          server_name = "xiaoxi654.dn42";
          ip_range_denylist = [];
          allowed_remote_server_names_experimental = [
            ".*\\.dn42$"
          ];
          well_known = {
            client = "https://matrix.xiaoxi654.dn42";
            server = "matrix.xiaoxi654.dn42:443";
          };
        };
      };
    };
  };
}
