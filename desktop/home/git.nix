{ ... }:

{
  programs.git = {
    enabble = true;
    userEmail = "xiaoxi654@outlook.com";
    userName = "Yoshida Kanae";
    signing = {
      signByDefault = true;
      key = "088507A7";
    };
  };
}