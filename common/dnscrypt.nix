{ pkgs, ... }: {
  services.dnscrypt-proxy = {
    enable = true;
    upstreamDefaults = true;

    settings = {
      anonymized_dns = {
        routes = [
          {
            server_name = "*";
            via = [
              "anon-cs-berlin"
              "anon-cs-berlin6"
              "anon-cs-de"
              "anon-cs-de6"
              "anon-cs-dus"
              "anon-cs-dus6"
              "anon-digitalprivacy.diy-ipv4"
              "odohrelay-crypto-sx"
            ];
          }
        ];

        skip_incompatible = true;
      };

      disabled_server_names = [
        "cs-berlin"
        "cs-berlin6"
        "cs-de"
        "cs-de6"
        "cs-dus"
        "cs-dus6"
        "digitalprivacy.diy-dnscrypt-ipv4"
        "odoh-crypto-sx"
      ];

      bootstrap_resolvers = [
        "9.9.9.9:53"
        "149.112.112.112:53"
        "1.1.1.1:53"
      ];

      cache = true;
      cache_size = 1000000;

      cloaking_rules = pkgs.writeText "dnscrypt-cloaking" ''
        bunny bunny.bunny.vpn
        laniakea laniakea.bunny.vpn
        local.host 127.0.0.1
        localhost 127.0.0.1
      '';

      forwarding_rules = pkgs.writeText "dnscrypt-forwarding" ''
        bunny.vpn 100.100.100.100
        lan 192.168.2.1
        vm 192.168.122.1
      '';

      dnscrypt_servers = true;
      doh_servers = false;
      odoh_servers = true;

      http3 = true;
      ipv4_servers = true;
      ipv6_servers = true;

      require_dnssec = true;
      require_nofilter = true;
      require_nolog = true;

      listen_addresses = [
        "127.0.0.1:53"
        "[::1]:53"
      ];

      # TODO
      # local_doh = {
      #   cert_file = "/persist/var/lib/dnscrypt-proxy2-doh.crt";
      #   cert_key_file = "/run/credentials/dnscrypt-proxy.service/key";
      #   listen_addresses = [
      #     "127.0.0.1:853"
      #     "[::1]:853"
      #   ];
      #   path = "/dns-query";
      # };

      monitoring_ui = {
        enabled = true;
        listen_address = "127.0.0.1:53080";
        password = "";
        privacy_level = 0;
        username = "";
      };

      query_log = { file = "/dev/stdout"; };

      sources = {
        dnscry-pt-resolvers = {
          cache_file = "/var/cache/dnscrypt-proxy/dnscry.pt-resolvers.md";
          minisign_key = "RWQM31Nwkqh01x88SvrBL8djp1NH56Rb4mKLHz16K7qsXgEomnDv6ziQ";
          prefix = "dnscry.pt-";
          refresh_delay = 73;
          urls = [ "https://www.dnscry.pt/resolvers.md" ];
        };

        odoh-relays = {
          cache_file = "/var/cache/dnscrypt-proxy/odoh-relays.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 73;
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-relays.md"
            "https://download.dnscrypt.info/resolvers-list/v3/odoh-relays.md"
          ];
        };

        odoh-servers = {
          cache_file = "/var/cache/dnscrypt-proxy/odoh-servers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 73;
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/odoh-servers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/odoh-servers.md"
          ];
        };

        public-resolvers = {
          cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 73;
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
            "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
          ];
        };

        quad9-resolvers = {
          cache_file = "/var/cache/dnscrypt-proxy/quad9-resolvers.md";
          minisign_key = "RWTp2E4t64BrL651lEiDLNon+DqzPG4jhZ97pfdNkcq1VDdocLKvl5FW";
          prefix = "quad9-";
          urls = [
            "https://raw.githubusercontent.com/Quad9DNS/dnscrypt-settings/main/dnscrypt/quad9-resolvers.md"
            "https://quad9.net/dnscrypt/quad9-resolvers.md"
          ];
        };

        relays = {
          cache_file = "/var/cache/dnscrypt-proxy/relays.md";
          minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
          refresh_delay = 73;
          urls = [
            "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/relays.md"
            "https://download.dnscrypt.info/resolvers-list/v3/relays.md"
          ];
        };
      };
    };
  };

  networking = {
    nameservers = [ "127.0.0.1" ];
    networkmanager.dns = "none";
    resolvconf.useLocalResolver = true;
  };

  services.resolved.enable = false;
}
