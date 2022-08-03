{ config, pkgs, ... }:

{
  imports = [
    ./home
  ];

  home.username = "xiaoxi";
  home.homeDirectory = "/home/xiaoxi";

  home.stateVersion = "22.05";  # DON'T TOUCH IT
}
