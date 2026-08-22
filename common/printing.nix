{ pkgs, config, lib, ... }: {
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    # disabledDefaultBackends = [ "escl" ];
    openFirewall = true;
  };

  services = {
    udev.packages = [ pkgs.sane-airscan ];

    avahi = {
      enable = true;
      openFirewall = true;
    };

    printing = {
      enable = true;

      drivers = with pkgs; [
        cups-browsed
        cups-filters
      ];
    };
  };

  aquaris = {
    dnscrypt.rules.forwarding = {
      ${config.services.avahi.domainName} = "0.0.0.0:5354";
    };

    persist.dirs = {
      "/var/lib/cups" = { };
    };
  };

  systemd.services.avahi-proxy = {
    serviceConfig.ExecStart = builtins.concatStringsSep " " [
      "${lib.getExe pkgs.avahi-proxy} run"
      "--baseDomain ${config.services.avahi.domainName}"
    ];

    wantedBy = [ "multi-user.target" ];
  };

  users.users = builtins.mapAttrs
    (_: _: { extraGroups = [ "lp" "scanner" ]; })
    config.aquaris.users;
}
