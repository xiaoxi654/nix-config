{ config, lib, pkgs, ... }:

let
  repoPath = "/var/lib/dn42_registry";
  repoUrl = "git@git.dn42.dev:dn42/registry.git";
in
{
  sops.secrets.dn42_registry_ssh_key = { };

  environment.systemPackages = with pkgs; [
    dn42-registry-wizard
    git
  ];

  systemd = {
    timers."dn42-registry-update" = {
      description = "Auto Pull DN42 Regsitry Repo";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "15m";
        OnUnitActiveSec = "2h";
        RandomizedDelaySec = "15m";
        AccuracySec = "5min";
        Unit = "dn42-registry-update.service";
      };
    };
    services = {
      "dn42-registry-update" = {
        description = "Pull DN42 Registry Repo";
        wantedBy = [ "multi-user.target" ];
        preStart = ''
          cp ${config.sops.secrets.dn42_registry_ssh_key.path} /tmp/dn42-registry-id_ed25519
          chmod 600 /tmp/dn42-registry-id_ed25519
          if [ ! -d "${repoPath}/.git" ]; then
            echo "Repository not found, cloning..."
            mkdir -p "${repoPath}"
            ${pkgs.git}/bin/git -c core.sshCommand="${pkgs.openssh}/bin/ssh -i /tmp/dn42-registry-id_ed25519 -o StrictHostKeyChecking=no" clone "${repoUrl}" "${repoPath}"
          fi
        '';
        script = ''
          cd "${repoPath}"
          ${pkgs.git}/bin/git -c core.sshCommand="${pkgs.openssh}/bin/ssh -i /tmp/dn42-registry-id_ed25519 -o StrictHostKeyChecking=no" fetch --all --prune
          ${pkgs.git}/bin/git reset --hard origin/master
          ${pkgs.git}/bin/git clean -fdx
          rm -f /tmp/dn42-registry-id_ed25519
          ${pkgs.procps}/bin/pkill -f -SIGUSR1 dn42-registry-wizard
        '';
        serviceConfig = {
          Type         = "oneshot";
          StateDirectory   = "dn42_registry";
          ProtectSystem    = "strict";
          ProtectHome      = "true";
          PrivateTmp       = "true";
          NoNewPrivileges  = "true";
          TimeoutStartSec  = 300;
        };
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
      };
      "dn42-registry-wizard" = {
        description = "DN42 Registry Wizard";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target"];
        after = [ "network-online.target"];
        path = [ pkgs.git ];
        serviceConfig = {
          Type = "simple";
          ExecStart = ''${pkgs.dn42-registry-wizard}/bin/dn42-registry-wizard ${repoPath} explorer'';
        };
      };
    };
  };
}
