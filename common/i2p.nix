{
  services.i2pd = {
    enable = true;
    settings = {
      http.enabled = false;
      socksproxy.enabled = true;
    };
  };

  aquaris.persist.dirs = {
    "/var/lib/i2pd" = {
      u = "i2pd";
      g = "i2pd";
    };
  };
}
