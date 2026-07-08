{
  environment.sessionVariables = {
    "MOZ_DISABLE_RDD_SANDBOX" = "1";
  };

  home-manager.sharedModules = [{
    aquaris.firefox = {
      enable = true;

      prefs = {
        "privacy.resistFingerprinting" = false;

        # can't connect to livekit calls when DTLS v1.3 (772) is enabled
        # https://bugzilla.mozilla.org/show_bug.cgi?id=2033783
        "media.peerconnection.dtls.version.max" = 771;
      };
    };
  }];
}
