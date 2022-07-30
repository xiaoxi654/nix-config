{ pkgs, ... }:

{
  home.packages = with pkgs; [
    file
    neofetch
    rnix-lsp
    element-desktop
    teamspeak_client
  ];
}
