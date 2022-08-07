{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home
  ];

  nixpkgs.overlays = [
    inputs.polymc.overlay
  ];

  home.username = "xiaoxi";
  home.homeDirectory = "/home/xiaoxi";
  home.stateVersion = "22.05";  # DON'T TOUCH IT
}
