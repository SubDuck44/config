{ pkgs, ... }: {
  boot.extraModprobeConfig =
    let
      script = pkgs.lib.getExe (pkgs.writeShellApplication {
        name = "audio-config";
        runtimeInputs = with pkgs; [ kmod alsa-utils ];
        text = ''
          modprobe -C /dev/null snd-hda-intel

          dir="/sys/class/sound/hwC3D0"
          while [ ! -e "$dir" ]; do sleep 0.25; done

          while read -r line; do echo "$line" > "$dir/hints"; done << EOF
          indep_hp = true
          vmaster = false
          EOF

          while read -r line; do echo "$line" > "$dir/user_pin_configs"; done << EOF
          0x11 0x40000000
          0x12 0x40000000
          0x14 0x01114010
          0x15 0x40000000
          0x16 0x40000000
          0x17 0x40000000
          0x18 0x40000000
          0x19 0x40000000
          0x1a 0x40000000
          0x1b 0x02214020
          0x1c 0x40000000
          0x1d 0x40000000
          0x1e 0x40000000
          0x1f 0x40000000
          EOF

          echo 1 > "$dir/reconfig"

          while ! amixer -c3 sset 'Independent HP' Enabled; do :; done
        '';
      });
    in
    ''
      install snd-hda-intel ${script}
    '';

  hardware.alsa.enablePersistence = true;

  services.udev.extraRules = ''
    SUBSYSTEMS=="pci", ATTRS{vendor}=="0x1022", ATTRS{device}=="0x15e3", \
    ENV{ACP_PROFILE_SET}="${./profile.conf}"
  '';

  aquaris.persist.dirs = {
    "/var/lib/alsa" = { };
  };

  environment.systemPackages = with pkgs; [ alsa-utils ];
}
