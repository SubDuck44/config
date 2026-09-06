{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-color-emoji
      merriweather
      overused-grotesk
      courier-prime
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };
}
