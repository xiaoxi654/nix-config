{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    screen
    htop
    gitMinimal
    file
    socat
    nix-top
  ];
}
