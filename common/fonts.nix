{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      ark-pixel-font
      cardo
      courier-prime
      departure-mono
      inter
      merriweather
      minecraftia
      nerd-fonts.cousine
      nerd-fonts.iosevka-term
      noto-fonts
      noto-fonts-color-emoji
      overused-grotesk
      raleway
    ];

    fontconfig.defaultFonts = {
      emoji = [ "Noto Color Emoji" ];
      monospace = [ "IosevkaTerm Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      serif = [ "Noto Serif" ];
    };
  };
}
