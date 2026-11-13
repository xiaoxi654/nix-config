{ config, lib, pkgs, ... }:

{
  # 与 nix-config 现有模块一致：sops 密钥在使用它的模块里声明。
  sops.secrets.eagler_turn_secret = {
    owner = "turnserver";
    mode = "0400";
  };

  services.coturn = {
    enable = true;

    # 玩家访问的地址；dn42 场景绑定 dn42 地址，公网场景换成公网地址。
    listening-ips = [ "10.127.101.51" ];
    relay-ips = [ "10.127.101.51" ];
    realm = "turn.xiaoxi654.dn42";

    listening-port = 3478;
    tls-listening-port = 5349;
    min-port = 49152;
    max-port = 65535;

    # TURN REST：Relay 用同一密钥签发短期凭据。
    lt-cred-mech = true;
    use-auth-secret = true;
    static-auth-secret-file = config.sops.secrets.eagler_turn_secret.path;

    # 未配置证书时不开放 TLS/DTLS。
    no-tls = true;
    no-dtls = true;
    no-cli = true;

    # 与 relay 模块中的保守配额一致（约 10 Mbps 出口）。
    extraConfig = ''
      user-quota=12
      total-quota=256
      max-bps=131072
      bps-capacity=786432
    '';
  };

  networking.firewall = {
    allowedUDPPorts = [ 3478 3479 ];
    allowedTCPPorts = [ 3478 3479 ];
    allowedUDPPortRanges = [ { from = 49152; to = 65535; } ];
  };
}
