{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.iosevka
      noto-fonts
      noto-fonts-color-emoji
      merriweather
      cardo
      overused-grotesk
      courier-prime
      nerd-fonts.cousine
      raleway
      inter
      minecraftia
      ark-pixel-font
      departure-mono
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaNerdFont" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };
}
