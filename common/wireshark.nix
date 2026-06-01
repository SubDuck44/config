{ pkgs, ...}: {
  programs.wireshark = {
    enable = true;
    usbmon.enable = true;
    package = pkgs.wireshark;
  };

  users.users.melinda.extraGroups = [ "wireshark" ];
}
