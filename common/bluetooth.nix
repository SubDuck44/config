{
  hardware.bluetooth = {
    enable = true;
    settings.General.Experimental = true;
  };

  aquaris.persist.dirs = {
    "/var/lib/bluetooth" = { m = "0700"; };
  };
}
