{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./java-ca.nix
      ./matrix-server.nix
      ./dn42-registry-wizard.nix
      ./caddy.nix
      ./drasl.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos-matrix";
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Shanghai";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
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
  services.openssh.enable = true;

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
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  security.sudo.wheelNeedsPassword = false;

  # Enable nix-ld
  programs.nix-ld.enable = true;

  services.qemuGuest.enable = true;

  # DO NOT TOUCH THIS OPTION UNLESS YOU KNOW WHAT ARE YOU DOING!
  system.stateVersion = "25.11";

}
