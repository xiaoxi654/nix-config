# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  sops.secrets = {
    "transmission.json" = {
      format = "binary";
      sopsFile = ../../secrets/transmission.json;
      owner = "transmission";
      group = "transmission";
    };
  };

  nix = {
    package = pkgs.nixUnstable;
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
    interfaces = {
      ens18 = {
        ipv4.addresses = [
          {
            address = "10.0.1.110";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2a01:4f9:4a:286f:1:110::1";
            prefixLength = 96;
          }
        ];
      };
      ens19 = {
        ipv4.addresses = [
          {
            address = "10.0.2.110";
            prefixLength = 24;
          }
        ];
        ipv6.addresses = [
          {
            address = "2605:6400:c6fe:110::1";
            prefixLength = 64;
          }
        ];
      };
    };
    defaultGateway = {
      address = "10.0.2.1";
      interface = "ens19";
    };
    defaultGateway6 = {
      address = "2605:6400:c6fe::1";
      interface = "ens19";
    };
    nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
    ];
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
      "transmission"
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

  services = {
    openssh = {
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
          addr = "[::]";
          port = 22;
        }
        {
          addr = "0.0.0.0";
          port = 21000;
        }
      ];
    };
    transmission = {
      enable = true;
      openPeerPorts = true;
      openRPCPort = true;
      settings ={
        rpc-port = 21001;
        peer-port = 21020;
        rpc-bind-address = "0.0.0.0";
      };
      credentialsFile = "/run/secrets/transmission.json";
    };
  };

  system.stateVersion = "22.05"; # DON'T TOUCH IT
}

