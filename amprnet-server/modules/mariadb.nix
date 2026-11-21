{ config, lib, pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

    # Wavelog connects via the unix socket; no reason to listen on any IP.
    settings.mysqld.bind-address = "127.0.0.1";
    ensureDatabases = [ "wavelog" ];

    ensureUsers = [
      {
        name = "wavelog";
        ensurePermissions = {
          "wavelog.*" = "ALL PRIVILEGES";
        };
      }
    ];
  };
}
