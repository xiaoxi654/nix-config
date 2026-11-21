# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/caddy.nix
      ./modules/wavelog.nix
      ./modules/mariadb.nix
      ./modules/thelounge.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 3;
  time.timeZone = "America/Vancouver";
  i18n.defaultLocale = "en_US.UTF-8";
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "xiaoxi" ];
  };
  security.sudo.wheelNeedsPassword = false;

  networking.hostName = "izuminet-ham";
  networking.useNetworkd = true;
  systemd.network = {
    enable = true;
    networks = {
      ens18 = {
        enable = true;
        DHCP = "yes";
        matchConfig = {
          Name = "ens18";
        };
        networkConfig = {
          IPv6AcceptRA = true;
        };
      };
    };
  };

  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.sops.secrets.xiaoxi_passwd.path;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFwjywVaKzp0NAzG9azWjif1dZu6KXHQjQUA3Aw5uGT" ];
  };

  # sops-nix: decrypt secrets at activation using the target host key
  # (same setup as MatrixServer; systemd activation avoids the
  # deprecated activation-script path).
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.useSystemdActivation = true;

  # xiaoxi's Argon2id password hash, previously committed in plaintext
  # here. neededForUsers decrypts it before users are created.
  sops.secrets.xiaoxi_passwd = {
    sopsFile = ./secrets/passwd.yaml;
    neededForUsers = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  programs.mtr.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  # DO NOT TOUCH THIS OPTION UNLESS YOU KNOW WHAT ARE YOU DOING!
  system.stateVersion = "26.05";

}
