{ self, lib, ... }: {
  nixpkgs.overlays = lib.singleton (_: prev:
    let obscura = self.inputs.obscura.packages.${prev.stdenv.system}; in
    self.inputs.obscura.lib.infuse prev ({
      nix-output-monitor.__assign = obscura.my-nom;
      prettypst.__assign = obscura.my-prettypst;

      wivrn.__output = {
        version.__assign = "26.6";
        src.__output.hash.__assign = "sha256-0RvQnaxASPcv3JkEp1OON/n4C9qEAAJ8R7m2FKPlVK0=";

        monado.__output.src.__assign = prev.fetchFromGitLab {
          domain = "gitlab.freedesktop.org";
          owner = "monado";
          repo = "monado";
          rev = "1b526bb3a0ff326ecd05af4c2c541407f53c6d4b";
          hash = "sha256-SzuCQ1uX15vFGwGt3gswlVF2Su8sIND4R3tsTJ4T1LY=";
        };

        nativeBuildInputs.__append = with prev; [
          hexdump
        ];

        buildInputs.__append = with prev; [
          kdePackages.kirigami-addons
        ];

        cmakeFlags.__append = [
          "-DGIT_COMMIT=26.6"
        ];
      };

      factorio-space-age.__input.makeDesktopItem.__hijack.exec.__prepend = "gamemoderun ";

      syncplay.__output = {
        patches.__append = [
          ./syncplay.patch
        ];

        postFixup.__append = ''
          rm $out/share/applications/syncplay-server.desktop
          sed -Ei 's|(Exec=syncplay .*)|\1 --no-store|' \
            $out/share/applications/syncplay.desktop
        '';
      };
    } // builtins.mapAttrs (_: x: { __assign = x; }) {
      inherit (obscura)
        keysmash
        yellowcake
        ;

      inherit (obscura.nvidia.entries) nvtop;
    }));
}
