{
  home-manager.sharedModules = [{
    aquaris.firefox = {
      enable = true;

      prefs = {
        "privacy.resistFingerprinting" = false;
      };
    };
  }];
}
