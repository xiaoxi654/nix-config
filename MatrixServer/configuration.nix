{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/java-ca.nix
      ./modules/matrix-server.nix
      ./modules/dn42-registry-wizard.nix
      ./modules/caddy.nix
      ./modules/mail.nix
      ./modules/drasl.nix
      ./modules/eagler-touhou.nix
      ./modules/eagler-turn.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  networking.hostName = "nixos-matrix";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnQzm0m6//bLp280evhqpKpiZzId73nCvFYfxWorgvh xiaoxi@DESKTOP-DGBCL6B"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFwjywVaKzp0NAzG9azWjif1dZu6KXHQjQUA3Aw5uGT laptop_gentoo"
    ];
  };

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    screen
  ];

  programs.mtr.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    22
    80
    443
    25565
  ];
  networking.firewall.allowedUDPPorts = [
    80
    443
  ];
  networking.firewall.allowPing = true;
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Nix Settings
  nix.settings = {
    substituters = [ "https://mirrors.ustc.edu.cn/nix-channels/store" ];
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "xiaoxi" ];
  };
  # Enable DN42 CA
  security.pki.certificateFiles = [ "${pkgs.dn42-cacert}/etc/ssl/certs/dn42-ca.crt" ];

  # sops-nix: decrypt secrets at activation using the target host key.
  # useSystemdActivation installs secrets from sops-install-secrets.service
  # (sysinit) instead of the activation script; restartUnits/reloadUnits then
  # call systemctl directly. The activation-script path is deprecated
  # (WARN) and removed in NixOS 26.11.
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.useSystemdActivation = true;

  security.sudo.wheelNeedsPassword = false;

  # Enable nix-ld
  programs.nix-ld.enable = true;

  services.qemuGuest.enable = true;

  # DO NOT TOUCH THIS OPTION UNLESS YOU KNOW WHAT ARE YOU DOING!
  system.stateVersion = "25.11";

}
