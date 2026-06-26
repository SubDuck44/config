{
  services.i2pd = {
    enable = true;

    proto.http.enable = false;
    proto.socksProxy.enable = true;
  };

  aquaris.persist.dirs = {
    "/var/lib/i2pd" = {
      u = "i2pd";
      g = "i2pd";
    };
  };
}
