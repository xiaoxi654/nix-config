# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ system, config, pkgs, ... }:

{
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

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    supportedLocales = [
      "C.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
  };
  
  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    description = "Kanae Yoshida";
    home = "/home/xiaoxi";
  };

  system.stateVersion = "22.05"; # DON'T TOUCH IT
}
