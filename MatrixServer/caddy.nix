{config, lib, pkgs, ...}:

{
  services = {
    caddy = {
      enable = true;
      configFile = pkgs.writeText "Caddyfile" ''
        pbh.xiaoxi654.dn42 {
          bind 10.127.101.51
          bind fdec:4f96:8be1:102:24d6:dda2:60d5:158c
          tls {
            issuer acme https://acme.burble.dn42/v1/dn42/acme/directory
          }
          reverse_proxy unraid.xiaoxi654.dn42:9898
        }
        dol.xiaoxi654.dn42 {
          bind 10.127.101.51
          bind fdec:4f96:8be1:102:24d6:dda2:60d5:158c
          tls {
            issuer acme https://acme.burble.dn42/v1/dn42/acme/directory {
              disable_tlsalpn_challenge
            }
          }
          root /srv/dol
          file_server
          encode zstd gzip
        }
        matrix.xiaoxi654.dn42 {
          bind 10.127.101.51
          bind fdec:4f96:8be1:102:24d6:dda2:60d5:158c
          tls {
            issuer acme https://acme.burble.dn42/v1/dn42/acme/directory {
              disable_tlsalpn_challenge
            }
          }
          reverse_proxy 127.0.0.1:6167
        }
        explorer.xiaoxi654.dn42 {
          bind 10.127.101.51
          bind fdec:4f96:8be1:102:24d6:dda2:60d5:158c
          tls {
            issuer acme https://acme.burble.dn42/v1/dn42/acme/directory {
              disable_tlsalpn_challenge
            }
          }
          reverse_proxy 127.0.0.1:8080
        }
        ai.xiaoxi654.dn42 {
          bind 10.127.101.51
          bind fdec:4f96:8be1:102:24d6:dda2:60d5:158c
          tls {
            issuer acme https://acme.burble.dn42/v1/dn42/acme/directory {
              disable_tlsalpn_challenge
            }
          }
          reverse_proxy unraid.xiaoxi654.dn42:3700
        }
        ygg.xiaoxi654.dn42 {
          bind 10.127.101.51
          bind fdec:4f96:8be1:102:24d6:dda2:60d5:158c
          tls {
            issuer acme https://acme.burble.dn42/v1/dn42/acme/directory {
              disable_tlsalpn_challenge
            }
          }
          reverse_proxy 127.0.0.1:8001
        }
      '';
    };
  };
}
