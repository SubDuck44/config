{ modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/persist" = {
    device = "rpool/nixos/persist";
    fsType = "zfs";
    options = [ "zfsutil" "nosuid" ];
  };

  fileSystems."/nix" = {
    device = "rpool/nixos/nix";
    fsType = "zfs";
    options = [ "zfsutil" "nosuid" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/30B4-0953";
    fsType = "vfat";
    options = [ "fmask=0022" "dmask=0022" "nosuid" ];
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;
}
