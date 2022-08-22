# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings.trusted-users = [ "xiaoxi" ];
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub = {
    enable = true;
    version = 2;
    device = "/dev/sda";
  };

  networking = {
    hostName = "xiaoxi-nixos-storage";
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = [
        22
      ];
      allowedTCPPortRanges = [
        {
          from = 21000;
          to = 21099;
        }
      ];
      # allowedUDPPorts = [ ... ];
    };
  };
  
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";

  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    hashedPassword = "$6$E9btBHOwH0EhtQNp$q0GW7U/73qJ3fJqMtaP07nVOSzDyYLueIYezQ2KzhxdZJwrPA1xZKNnj.Y8zkyw.qaZpOmTLOuXvlfS3B8V84/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLLnthJp2VrLQMmd3xnzPfu3fxpXrCaVPc7+R3tG6EDrxCLahoHbItJgPTQABJd3728w4M1ipMCIQB3MTKgRZ9Hz654aPVdclnBLuKFl+niYBMUbV+UtZqhV7Wlecsc+6+snaACoqGvJbdJEueYghXPkf1imLt7Gf8dQ7rzBkzV3Kly/LNLmonQpvFIG7LNYMqqVrWPi/JWrBk7tyE2wTJH8RyN4uAo12vJQqzmQSFpl8T6PNq4xUA8M427g+lH/w6hb9kPFEx7mZDstkCoYPqno2m6w4BCL3rMWw/GtM7wkGp7E+PfFcs0igPppV/+/a3FFp95sMvVVStPvWNTyOochgWMx07y2Wxfrtugqo498Bu/AFacIkHbBsto4xI6kcssS811M5Kh2H6unZgR7LsUosKwQ1Gj6IejyFYJs+o8+qbFFpcMSb3EwR0t0O7/Uj+rhFR0v+52mcgpQZ0+Xy7vIAbuDCorAB0ITNyJrzuZQUPX3CaKMIHit2YQZzMMWuiSqnewhPi8FDIYFqFtoYj2GRvXywxrXFs9G6+euRNo5GeIPxeUBnmecFSOCiOdBjI5fxpnXj7EL3aqFLeACmaUGbETszOodIygeGbaiMuOlIw/v0C8I+lyQfVd8nI88HkLVoQtjF8sRT37UHzDDCMjpB3655NfyHAjdGWNhQ1GQ=="
    ];
    description = "Kanae Yoshida";
    home = "/home/xiaoxi";
  };

  programs.mtr.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  services.openssh = {
    enable = true;
    banner = ''
      Welcone to Xiaoxi654's Storage Server
      This server only accept public key authentication
    '';
    permitRootLogin = "no";
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    listenAddresses = [
      {
        addr = "[2a01:4f9:4a:286f:1:110::1]";
        port = 22;
      }
      {
        addr = "0.0.0.0";
        port = 21000;
      }
    ];
  };

  system.stateVersion = "22.05"; # DON'T TOUCH IT
}

