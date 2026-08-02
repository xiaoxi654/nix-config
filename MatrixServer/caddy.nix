{ ... }:

{
  services = {
    caddy = {
      enable = true;
      configFile = ./configs/Caddyfile;
    };
  };
}
