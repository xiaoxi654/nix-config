{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    screen
    htop
    file
    nix-top
    stdenv.cc.cc.lib
  ];
}
