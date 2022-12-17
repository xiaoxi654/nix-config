{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    # Temp fix
    nvidiaPatches = true;
  };
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDER_LIBRARY_NAME = "nvidia";
    WLR_NO_HARDWARE_CURSORS = "1";
    GDK_BACKEND = "wayland,x11";
    NIXOS_OZONE_WL = "1";
  };
  environment.systemPackages = with pkgs; [
    wofi
    dolphin
    waybar
    dunst
    slurp
  ];
}
