{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
      device = "/dev/disk/by-uuid/1e688d45-0299-4972-adb7-545b9c3802e8";
      fsType = "btrfs";
      options = [ "subvol=_subvolume/@" "compress-force=zstd" ];
    };

  fileSystems."/home" = {
      device = "/dev/disk/by-uuid/1e688d45-0299-4972-adb7-545b9c3802e8";
      fsType = "btrfs";
      options = [ "subvol=_subvolume/@home" "compress-force=zstd" ];
    };

  fileSystems."/boot/efi" = {
      device = "/dev/disk/by-uuid/318F-915C";
      fsType = "vfat";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
