{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # NVIDIA Driver
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.modesetting.enable = true;

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8cbd2df6-d1df-4a00-88dd-a59fb02557c7";
      fsType = "btrfs";
      options = [ "subvol=@" "compress-force=zstd" ];
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/8cbd2df6-d1df-4a00-88dd-a59fb02557c7";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress-force=zstd" ];
    };

  fileSystems."/boot/efi" =
    { device = "/dev/disk/by-uuid/318F-915C";
      fsType = "vfat";
    };

  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
