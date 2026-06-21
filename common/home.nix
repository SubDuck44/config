{ pkgs, lib, config, self, ... }: {
  aquaris = {
    unfreeNames = [
      "aseprite"
      "p7zip"
    ];
  };

  home-manager.sharedModules = lib.singleton (hm: {
    home = {
      stateVersion = "25.11";

      packages = with pkgs; [
        aseprite
        chatterino7
        ckan
        cmatrix
        equibop
        espeak
        feh
        ffmpeg
        godot
        lazpaint
        libnotify
        libqalculate
        mindustry-wayland
        mpv
        nvtop
        p7zip-rar
        playerctl
        poppler-utils
        pulsemixer
        pwgen
        qbittorrent
        self.inputs.keysmash.packages.${pkgs.stdenv.system}.default
        swaybg
        thunderbird
        umu-launcher
        wl-clipboard
      ];

      shellAliases = {
        auto = "espeak -p 0 -P 0";
        sneeptime = "systemctl suspend";
        crush = "nix store gc -v";
        judgement = "systemctl --user restart emacs";
        thy-end-is-now = "sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system";
        emacs = "emacsclient -nc";
      };

      sessionVariables = {
        NIXOS_CONFIG_DIR = ''$(realpath "$HOME/cfg")'';
      };
    };

    services = {
      syncthing.enable = true;
    };

    programs = {
      foot = {
        enable = true;
        settings = {
          colors-dark.alpha = 0.0;
          main.include = "${pkgs.foot.themes}/share/foot/themes/gruvbox-dark";
        };
      };

      fuzzel.enable = true;
    };

    aquaris.git.sshKeyFile = _: config.aquaris.secret "user/${hm.config.home.username}/ssh/main";
    aquaris.persist = {
      "cfg" = { };
      "cod" = { };
      "doc" = { };
      "gay" = { };
      "gps" = { };
      "img" = { };
      "mem" = { };
      "mov" = { };
      "org" = { };
      "rnd" = { };
      "sfx" = { };

      ".thunderbird" = { };

      ".cache/thunderbird" = { };

      ".config/aseprite" = { };
      ".config/dconf" = { };
      ".config/equibop" = { };
      ".config/qBittorrent" = { };
      ".config/qalculate" = { };

      ".local/share/CKAN" = { };
      ".local/share/Mindustry" = { };
      ".local/share/applications" = { };
      ".local/share/chatterino" = { };
      ".local/share/qBittorrent" = { };
      ".local/share/umu" = { };

      ".local/state/syncthing" = { };
    };

    xdg.configFile."equibop-flags.conf".text = ''
      --wayland
    '';
  });
}
