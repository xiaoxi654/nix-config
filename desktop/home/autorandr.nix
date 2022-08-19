{ ... }:

{
  programs.autorandr = {
    enable = true;
    profiles = {
      desktop = {
        fingerprint = {
          DP-2 = "00ffffffffffff00047291057e2a2192161d0104b5361e783f9055a75553a028135054bfef80714f8140818081c081009500b300d1c0023a801871382d40582c4500202f2100001e000000fd001e90a7a723010a202020202020000000fc004b47323531510a202020202020000000ff0054385a434e303032383535320a0159020318f14b010203040590111213141f23090707830100002a4480a07038274030203500202f2100001a866f80a07038404030203500202f2100001a5a8780a070384d4030203500202f2100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a4";
          DVI-D-0 = "00ffffffffffff0010ac4df0533443412718010380331d78eadd45a3554fa027125054a54b00714f8180a9c0d1c00101010101010101023a801871382d40582c4500fd1e1100001e000000ff00324d59395834394f414334530a000000fc0044454c4c204532333134480a20000000fd00384c1e5311000a2020202020200033";
        };
        config = {
          DP-2 = {
            enable = true;
            crtc = 0;
            primary = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "143.98";
          };
          DVI-D-0 = {
            enable = true;
            crtc = 1;
            position = "1920x0";
            mode = "1920x1080";
            rate = "60.00";
          };
        };
      };
    };
  };
}