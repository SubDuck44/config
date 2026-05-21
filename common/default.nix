{ aquaris, ... }: {
  imports = aquaris.lib.importDir ./.;

  aquaris = {
    machine.secureboot = false;
    persist.enable = true;
  };

  system.stateVersion = "25.11";

  boot.zfs.forceImportRoot = true;
}
