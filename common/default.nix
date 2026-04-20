{ aquaris, ... }: {
  imports = aquaris.lib.importDir ./.;

  aquaris = {
    machine.secureboot = false;
    persist.enable = true;
  };

  system.stateVersion = "25.11";

  fileSystems = {
    "/proc" = {
      device = "proc";
      fsType = "proc";
      options = [ "nosuid" "hidepid=invisible" "gid=1" ];
    };
  };
}
