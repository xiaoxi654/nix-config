# Eagler Touhou 联机 Relay 的 NixOS 服务定义（交接模板）。
# 由执行 Session 复制到 nix-config/MatrixServer/ 并按实际路径/域名调整后 import。
# 共享密钥由 sops 提供：eagler-turn.nix 声明密钥，本模块渲染 Relay 的 EnvironmentFile。
{ config, lib, pkgs, ... }:

let
  domain = "th.xiaoxi654.dn42";
  siteRoot = "/srv/eagler-touhou";
  relayRoot = "${siteRoot}/relay";
  stateDir = "/var/lib/eagler-touhou";
in
{
  # Relay 读取环境变量，用 sops 模板把同一密钥渲染成 EnvironmentFile。
  sops.templates."eagler-relay.env" = {
    content = ''
      EAGLER_NETPLAY_TURN_SHARED_SECRET=${config.sops.placeholder.eagler_turn_secret}
    '';
    owner = "eagler-touhou";
  };

  users.groups.eagler-touhou = { };
  users.users.eagler-touhou = {
    isSystemUser = true;
    group = "eagler-touhou";
    home = stateDir;
  };

  systemd.services.eagler-netplay-relay = {
    description = "Eagler Touhou netplay relay";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment = {
      EAGLER_NETPLAY_RELAY_HOST = "127.0.0.1";
      EAGLER_NETPLAY_RELAY_PORT = "18142";
      EAGLER_NETPLAY_GAMEPLAY_RELAY_FALLBACK = "0";
      EAGLER_NETPLAY_TRUSTED_PROXIES = "127.0.0.1";
      EAGLER_NETPLAY_STUN_URLS = "stun:stun.cloudflare.com:3478";
      EAGLER_NETPLAY_PUBLIC_NICKNAMES = "0";

      # 启用 TURN：密钥由 sops 通过 EnvironmentFile 注入。
      # 不启用 TURN 时删除这三行与 serviceConfig.EnvironmentFile。
      EAGLER_NETPLAY_TURN_URLS = "turn:turn.xiaoxi654.dn42:3478?transport=udp,turn:turn.xiaoxi654.dn42:3478?transport=tcp";
      EAGLER_NETPLAY_TURN_TTL_SECONDS = "3600";
    };
    serviceConfig = {
      Type = "simple";
      User = "eagler-touhou";
      Group = "eagler-touhou";
      WorkingDirectory = relayRoot;
      ExecStart = "${lib.getExe pkgs.nodejs_22} ${relayRoot}/server/netplay-relay.mjs";
      EnvironmentFile = config.sops.templates."eagler-relay.env".path;
      Restart = "on-failure";
      RestartSec = 2;
      StateDirectory = "eagler-touhou";
      StateDirectoryMode = "0700";
      UMask = "0077";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
      ReadWritePaths = [ stateDir ];
    };
  };

  # 可选：状态页数据服务（站点 /uptime/ 读取）。
  systemd.services.eagler-netplay-telemetry = {
    description = "Eagler Touhou uptime and netplay telemetry";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "simple";
      User = "eagler-touhou";
      Group = "eagler-touhou";
      WorkingDirectory = "${siteRoot}/tools/telemetry";
      ExecStart = "${lib.getExe pkgs.nodejs_22} ${siteRoot}/tools/telemetry/server/netplay-telemetry.mjs";
      Environment = [
        "EAGLER_NETPLAY_TELEMETRY_PORT=18153"
        "EAGLER_NETPLAY_TELEMETRY_ORIGIN=https://${domain}"
        "EAGLER_NETPLAY_TELEMETRY_STATE=${stateDir}/telemetry.json"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      StateDirectory = "eagler-touhou";
      StateDirectoryMode = "0700";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ stateDir ];
    };
  };
}
