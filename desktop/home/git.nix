{ ... }:

{
  programs.git = {
    enable = true;
    userEmail = "xiaoxi654@outlook.com";
    userName = "Yoshida Kanae";
    signing = {
      gpgPath = "${pkgs.resign}/bin/resign";
      signByDefault = true;
      key = "/run/user/1000/resign.grpc";
    };
  };
}
