# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./hardware/nvidia.nix
      ./software/pipewire.nix
      ./software/packages.nix
      ./software/steam.nix
      ./software/fcitx5.nix
      ./software/plasma.nix
    ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.xiaoxi = import ./home.nix;
  };
  
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
    experimental-features = nix-command flakes
    '';
    settings.substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      ];
  };

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
    grub = {
      devices = [ "nodev" ];
      efiSupport = true;
      enable = true;
      useOSProber = true;
    };
  };

  networking = {
    hostName = "xiaoxi-nixos-desktop";
    networkmanager.enable = true;
  };

  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "en_US.UTF-8";
  
  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    description = "Kanae Yoshida";
    home = "/home/xiaoxi";
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  system.stateVersion = "22.05"; # DON'T TOUCH IT

}
