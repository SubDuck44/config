{ pkgs, ... }: {
  specialisation.binbows.configuration = {
    boot = {
      kernelParams = [
        "initcall_blacklist=sysfb_init"
        "amd_iommu=on"
        "iommu=pt"
      ];

      blacklistedKernelModules = [
        "nouveau"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
        "snd_hda_intel"
      ];

      extraModprobeConfig = ''
        options vfio-pci ids=10de:2786,10de:22bc,1022:15e3 disable_vga=1
        options snd-hda-core gpu_bind=0
        options snd-hda-codec-hdmi enable_acomp=n
        options kvm ignore_msrs=1
      '';
    };

    systemd.services.start-binbows = {
      wantedBy = [ "multi-user.target" ];

      after = [ "libvirtd.service" ];
      wants = [ "libvirtd.service" ];

      path = with pkgs; [
        libvirt
      ];

      script = ''
        virsh -c qemu:///system start win12
      '';
    };

    virtualisation.libvirtd.hooks.qemu.binbows = pkgs.writeShellScript "binbows" ''
      if [ "$1" = "win12" ] && [ "$2" = "release" ]; then
        ${pkgs.systemd}/bin/systemctl reboot
      fi
    '';
  };
}
