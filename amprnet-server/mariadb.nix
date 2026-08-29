{ config, lib, pkgs, ... }:

{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;

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
