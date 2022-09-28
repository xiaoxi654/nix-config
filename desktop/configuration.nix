# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ system, config, pkgs, inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.xiaoxi = import ./home.nix;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlay
      (import "${inputs.xiaoxi-repo}/overlay.nix")
    ];
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

  boot = {
    kernelPackages = pkgs.linuxPackages_zen;
    loader = {
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
  };

  networking = {
    hostName = "xiaoxi-nixos-desktop";
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    kbdInteractiveAuthentication = false;
    permitRootLogin = "no";
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
    hashedPassword = "$6$E9btBHOwH0EhtQNp$q0GW7U/73qJ3fJqMtaP07nVOSzDyYLueIYezQ2KzhxdZJwrPA1xZKNnj.Y8zkyw.qaZpOmTLOuXvlfS3B8V84/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLLnthJp2VrLQMmd3xnzPfu3fxpXrCaVPc7+R3tG6EDrxCLahoHbItJgPTQABJd3728w4M1ipMCIQB3MTKgRZ9Hz654aPVdclnBLuKFl+niYBMUbV+UtZqhV7Wlecsc+6+snaACoqGvJbdJEueYghXPkf1imLt7Gf8dQ7rzBkzV3Kly/LNLmonQpvFIG7LNYMqqVrWPi/JWrBk7tyE2wTJH8RyN4uAo12vJQqzmQSFpl8T6PNq4xUA8M427g+lH/w6hb9kPFEx7mZDstkCoYPqno2m6w4BCL3rMWw/GtM7wkGp7E+PfFcs0igPppV/+/a3FFp95sMvVVStPvWNTyOochgWMx07y2Wxfrtugqo498Bu/AFacIkHbBsto4xI6kcssS811M5Kh2H6unZgR7LsUosKwQ1Gj6IejyFYJs+o8+qbFFpcMSb3EwR0t0O7/Uj+rhFR0v+52mcgpQZ0+Xy7vIAbuDCorAB0ITNyJrzuZQUPX3CaKMIHit2YQZzMMWuiSqnewhPi8FDIYFqFtoYj2GRvXywxrXFs9G6+euRNo5GeIPxeUBnmecFSOCiOdBjI5fxpnXj7EL3aqFLeACmaUGbETszOodIygeGbaiMuOlIw/v0C8I+lyQfVd8nI88HkLVoQtjF8sRT37UHzDDCMjpB3655NfyHAjdGWNhQ1GQ=="
    ];
    description = "Kanae Yoshida";
    home = "/home/xiaoxi";
  };

  system.stateVersion = "22.05"; # DON'T TOUCH IT
}
