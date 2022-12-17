{ system, config, pkgs, inputs, ... }:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.xiaoxi = {
      imports = [
        ./home.nix
        inputs.hyprland.homeManagerModules.default
      ];
    };
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlay
      (import "${inputs.xiaoxi-repo}/overlay.nix")
      (final: prev: {
        waybar = prev.waybar.overrideAttrs (old: {
          patchPhase = ''
            sed -i 's/zext_workspace_handle_v1_activate(workspace_handle_);/const std::string command = "hyprctl dispatch workspace " + name_;\n\tsystem(command.c_str());/g' src/modules/wlr/workspace_manager.cpp
          '';
          mesonFlags = old.mesonFlags ++ [ "-Dexperimental=true" ];
        });
      })
    ];
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      substituters = [
        "https://hyprland.cachix.org"
        "https://mirrors.ustc.edu.cn/nix-channels/store"
        "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
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
    firewall = {
      allowedTCPPorts = [
        8000
      ];
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

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = false;
      kbdInteractiveAuthentication = false;
      permitRootLogin = "no";
    };
  };

  users.users.xiaoxi = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
    ];
    hashedPassword = "$6$E9btBHOwH0EhtQNp$q0GW7U/73qJ3fJqMtaP07nVOSzDyYLueIYezQ2KzhxdZJwrPA1xZKNnj.Y8zkyw.qaZpOmTLOuXvlfS3B8V84/";
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLLnthJp2VrLQMmd3xnzPfu3fxpXrCaVPc7+R3tG6EDrxCLahoHbItJgPTQABJd3728w4M1ipMCIQB3MTKgRZ9Hz654aPVdclnBLuKFl+niYBMUbV+UtZqhV7Wlecsc+6+snaACoqGvJbdJEueYghXPkf1imLt7Gf8dQ7rzBkzV3Kly/LNLmonQpvFIG7LNYMqqVrWPi/JWrBk7tyE2wTJH8RyN4uAo12vJQqzmQSFpl8T6PNq4xUA8M427g+lH/w6hb9kPFEx7mZDstkCoYPqno2m6w4BCL3rMWw/GtM7wkGp7E+PfFcs0igPppV/+/a3FFp95sMvVVStPvWNTyOochgWMx07y2Wxfrtugqo498Bu/AFacIkHbBsto4xI6kcssS811M5Kh2H6unZgR7LsUosKwQ1Gj6IejyFYJs+o8+qbFFpcMSb3EwR0t0O7/Uj+rhFR0v+52mcgpQZ0+Xy7vIAbuDCorAB0ITNyJrzuZQUPX3CaKMIHit2YQZzMMWuiSqnewhPi8FDIYFqFtoYj2GRvXywxrXFs9G6+euRNo5GeIPxeUBnmecFSOCiOdBjI5fxpnXj7EL3aqFLeACmaUGbETszOodIygeGbaiMuOlIw/v0C8I+lyQfVd8nI88HkLVoQtjF8sRT37UHzDDCMjpB3655NfyHAjdGWNhQ1GQ=="
    ];
    description = "Kanae Yoshida";
    home = "/home/xiaoxi";
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  system.stateVersion = "22.11";  # DON'T TOUCH IT!

}

