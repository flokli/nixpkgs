{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "floppy" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/56f79ca5-7a0d-4100-9e8e-187b5a2c06e6";
      fsType = "ext3";
    };

  boot.initrd.luks.devices."crypt-root".device = "/dev/disk/by-uuid/39e0d765-2492-4cf1-a9e8-f13d1d9d0b03";
  boot.initrd.clevis.enable = true;
  boot.initrd.clevis.devices."crypt-root".secretFile = "/etc/nixos/clevis-secret.jwe";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7ceabcf4-1077-4071-b8f6-c974f90d49c9";
      fsType = "ext3";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/05bb7e4b-8a54-4a1e-833a-2b2a7fe07512"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth1.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
