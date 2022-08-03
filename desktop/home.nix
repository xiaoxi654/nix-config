{ config, pkgs, ... }:

{
  imports = [
    ./home
  ];

  programs = {
    mtr.enable = true;
  };

  home.sessionVariables = {
    SSH_AUTH_SOCK = "$XDG_RUNTIME_DIR/resign.ssh";
    SOPS_GPG_EXEC = "${pkgs.writeShellApplication {
      name = "gpg";
      text = ''
        ${pkgs.resign}/bin/resign -u ${resign-socket} "$@"
      '';
    }}/bin/gpg";
  };

  systemd.user = {
    targets.sway-session.Unit.Wants = [ "xdg-desktop-autostart.target" ];
    services.resign = {
      Install.WantedBy = [ "graphical-session.target" ];
      Unit.PartOf = [ "graphical-session.target" ];
      Unit.After = [ "graphical-session.target" ];
      Service = {
        Environment = [
          "PATH=${pkgs.lib.makeBinPath [ pkgs.pinentry-gtk2 ]}"
          "GTK2_RC_FILES=${config.home.sessionVariables.GTK2_RC_FILES}"
        ];
        ExecStart = "${pkgs.resign}/bin/resign-agent --grpc %t/resign.grpc --ssh %t/resign.ssh";
      };
    };
  };

  home.username = "xiaoxi";
  home.homeDirectory = "/home/xiaoxi";

  home.stateVersion = "22.05";  # DON'T TOUCH IT
}
