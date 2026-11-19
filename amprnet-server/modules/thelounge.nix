{ config, lib, pkgs, ... }:

{
  services = {
    thelounge = {
      enable = true;
      public = false;
      extraConfig = {
        reverseProxy = true;
      };
    };
  };
}
