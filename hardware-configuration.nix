{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "rpool/nixos/root";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/nix" = {
    device = "rpool/nixos/nix";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/home/melinda" = {
    device = "rpool/nixos/home/melinda";
    fsType = "zfs";
    options = [ "zfsutil" ];
  };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/30B4-0953";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
