{ config, lib, pkgs, ... }: {
  home-manager.sharedModules = [{
    home.packages = with pkgs; [
      flameshot
      grim
      slurp
      wl-clipboard

      (pkgs.writeShellApplication {
        name = "flameshot-run";
        text = ''
          flameshot gui -r | wl-copy &
          grep -m1 flameshot < <(nc -U "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock")
          pkill -SIGUSR1 waybar
          wait
          pkill -SIGUSR1 waybar
        '';
      })
    ];

    xdg.configFile."flameshot/flameshot.ini".source =
      (pkgs.formats.ini { }).generate "flameshot.ini" {
        General = {
          predefinedColorPaletteLarge = true;
          showAbortNotification = false;
          showDesktopNotification = false;
          showQuitPrompt = true;
        };
      };
  }];
}
