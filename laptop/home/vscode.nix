{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhs;
    extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      ms-ceintl.vscode-language-pack-zh-hans
      ms-vsliveshare.vsliveshare
      eamodio.gitlens
    ];
    userSettings = {
      "nix.enableLanguageServer" = true;
    };
  };
}
