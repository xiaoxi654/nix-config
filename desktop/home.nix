{ config, pkgs, inputs, ... }:

{
  imports = [
    ./home
  ];

  home.username = "xiaoxi";
  home.homeDirectory = "/home/xiaoxi";
  home.stateVersion = "22.11"; # DON'T TOUCH IT
}
