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
    pulseaudio  # For pactl
    stdenv.cc.cc.lib
  ];
}
