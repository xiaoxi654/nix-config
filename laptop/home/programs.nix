{ pkgs, ... }:

{
  programs = {
    git = {
      enable = true;
      userEmail = "xiaoxi654@outlook.com";
      userName = "Yoshida Kanae";
      signing = {
        signByDefault = true;
        key = "088507A7";
      };
      extraConfig = {
        pull.rebase = true;
      };
    };
    vscode = {
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
    rbw = {
      enable = true;
      settings = {
        email = "xiaoxi654@outlook.com";
        base_url = "https://srv.xiaoxi654.xyz/vault/";
      };
    };
  };
}
