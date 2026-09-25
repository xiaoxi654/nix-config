{ config, lib, pkgs, ... }:

let
  repoPath = "/var/lib/dn42_registry";
  repoUrl = "git@git.dn42.dev:dn42/registry.git";

  wizardUnit = "dn42-registry-wizard.service";
  wizardPort = 8080;

  systemctl = "${config.systemd.package}/bin/systemctl";
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
        OnBootSec = "1m";
        OnUnitActiveSec = "2h";
        RandomizedDelaySec = "15m";
        AccuracySec = "5min";
        Unit = "dn42-registry-update.service";
      };
    };
    services = {
      "dn42-registry-update" = {
        description = "Pull DN42 Registry Repo";

        wants = [ "network-online.target" ];
        after = [ "network-online.target" wizardUnit ];

        script = ''
          if [ ! -d "${repoPath}/.git" ]; then
            echo "Repository not found, cloning..."
            mkdir -p "${repoPath}"
            ${pkgs.git}/bin/git -c core.sshCommand="${pkgs.openssh}/bin/ssh -i ${config.sops.secrets.dn42_registry_ssh_key.path} -o StrictHostKeyChecking=no" clone "${repoUrl}" "${repoPath}"
          else
            cd "${repoPath}"
            ${pkgs.git}/bin/git -c core.sshCommand="${pkgs.openssh}/bin/ssh -i ${config.sops.secrets.dn42_registry_ssh_key.path} -o StrictHostKeyChecking=no" fetch --all --prune
            ${pkgs.git}/bin/git reset --hard origin/master
            ${pkgs.git}/bin/git clean -fdx
          fi

          if [ "$(${systemctl} show -p ActiveState --value ${wizardUnit})" = "active" ]; then
            tries=0
            while [ "$tries" -lt 60 ]; do
              tries=$((tries + 1))
              if ${pkgs.curl}/bin/curl -sf --max-time 5 -o /dev/null "http://127.0.0.1:${toString wizardPort}/api/index/"; then
                ${systemctl} reload ${wizardUnit} \
                  || echo "warning: failed to signal ${wizardUnit}, skipping data refresh" >&2
                break
              fi
              sleep 1
            done
          else
            echo "${wizardUnit} is not active, skipping data refresh"
          fi
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
      };
      "dn42-registry-wizard" = {
        description = "DN42 Registry Wizard";
        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target"];
        after = [ "network-online.target"];
        path = [ pkgs.git ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.dn42-registry-wizard}/bin/dn42-registry-wizard ${repoPath} explorer --port ${toString wizardPort}";

          ExecReload = "${pkgs.coreutils}/bin/kill -USR1 $MAINPID";

          Restart = "always";
          RestartSec = "5s";
        };
      };
    };
  };
}
