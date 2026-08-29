{ config, lib, pkgs, ... }:

let
  wavelogUser = "wavelog";
  webroot = "/var/lib/wavelog";

  # PHP extensions Wavelog needs beyond the NixOS defaults.
  extraPhpExtensions = [ "curl" "mbstring" "mysqli" "pdo_mysql" "zip" "gd" "apcu" "intl" ];
in
{
  # Make the packaged Wavelog code available under a stateful, writable webroot.
  # rsync -a overwrites changed code files and adds new ones, but never removes
  # files that only exist in the webroot. That keeps installer-generated config
  # (application/config/{config,database}.php) and all user data (logs, uploads,
  # backups, QSL cards, ...) intact across version updates.
  # --checksum is required because the Nix store normalises all mtimes to the
  # epoch, so timestamp-based sync would skip code changes.
  system.activationScripts.wavelog = lib.stringAfter [ "users" ] ''
    mkdir -p ${webroot}
    ${pkgs.rsync}/bin/rsync -a --no-owner --no-group --checksum ${pkgs.wavelog}/. ${webroot}/
    chown -R ${wavelogUser}:${wavelogUser} ${webroot}
    # Ensure the PHP user can write to the webroot even if the copied files
    # inherited read-only permissions from the Nix store.
    chmod -R u+rwX,go+rX ${webroot}
  '';

  users.groups.wavelog = { };

  users.users.wavelog = {
    isSystemUser = true;
    group = wavelogUser;
    home = webroot;
  };

  services.phpfpm.pools.wavelog = {
    user = wavelogUser;
    group = wavelogUser;

    phpPackage = pkgs.php83.withExtensions ({ enabled, all }:
      enabled
      ++ map (name: all.${name})
        (builtins.filter (name: !(builtins.elem name enabled)) extraPhpExtensions)
    );

    settings = {
      "listen.owner" = "caddy";
      "listen.group" = "caddy";
      "listen.mode" = "0660";
      "pm" = "dynamic";
      "pm.max_children" = "10";
      "pm.start_servers" = "2";
      "pm.min_spare_servers" = "1";
      "pm.max_spare_servers" = "5";
      "pm.max_requests" = "500";
      "catch_workers_output" = "yes";
    };

    phpOptions = ''
      memory_limit = 256M;
      upload_max_filesize = 64M;
      post_max_size = 64M;
      max_execution_time = 600;
      expose_php = Off;
      mysqli.default_socket = /run/mysqld/mysqld.sock;
    '';
  };
}
