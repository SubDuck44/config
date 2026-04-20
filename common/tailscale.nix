{
  aquaris.persist.dirs = {
    "/var/lib/tailscale" = { m = "0700"; };
  };

  services.tailscale = {
    enable = true;
    openFirewall = true;
    useRoutingFeatures = "client";
  };

  systemd.network.wait-online.enable = false;
}
