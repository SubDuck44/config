{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;

    extraConfig =
      let
        rt = {
          "module.rt.args" = {
            "rtportal.enabled" = false;
            "nice.level" = -11;
          };
        };

        quantum = 8192;
        clock = 192000;
      in
      {
        pipewire = {
          "00-realtime" = rt // {
            "context.properties" = {
              "default.clock.max-quantum" = quantum;
              "default.clock.min-quantum" = quantum;
              "default.clock.quantum" = quantum;
              "default.clock.rate" = clock;
            };
          };
        };

        pipewire-pulse = {
          "00-realtime" = rt;
        };
      };

    wireplumber.extraConfig = {
      "00-realtime" = {
        "monitor.alsa.rules" = [{
          matches = [{
            "device.name" = "~alsa_card.*";
          }];

          actions = {
            update-props = {
              "api.alsa.headroom" = 8192;
              "api.alsa.period-size" = 256;
            };
          };
        }];
      };
    };
  };

  home-manager.sharedModules = [{
    aquaris.persist = { ".local/state/wireplumber" = { }; };
  }];
}
