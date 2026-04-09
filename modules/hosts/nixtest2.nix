{ inputs, den, ... }:
{
  # nixtest2 — converted existing NixOS install (no disko, no impermanence).
  # Disk: /dev/sda1=vfat(/efi 100M), /dev/sda2=ext4(/ 14.9G), /swapfile 77M
  den.aspects.nixtest2 = {
    includes = [
      den.aspects.base-server
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.agenix.nixosModules.default
        ];

        # ── Hardware ──────────────────────────────────────────────────
        boot.initrd.availableKernelModules = [
          "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi"
          "sd_mod" "sr_mod" "ahci" "xen_blkfront" "vmw_pvscsi"
        ];

        # ── Filesystems (match existing install) ──────────────────────
        fileSystems."/" = {
          device = "/dev/disk/by-uuid/8acbcb7f-fec6-491f-95f3-4aa8e9bf1d0c";
          fsType = "ext4";
        };
        fileSystems."/efi" = {
          device = "/dev/disk/by-uuid/3D78-70E1";
          fsType = "vfat";
          options = [ "fmask=0077" "dmask=0077" ];
        };

        # ── Swap ──────────────────────────────────────────────────────
        swapDevices = [{ device = "/swapfile"; size = 77; }];

        # ── Bootloader ────────────────────────────────────────────────
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.efi.efiSysMountPoint = "/efi";
        boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];

        # ── Networking ────────────────────────────────────────────────
        networking.hostName = "nixtest2";
        networking.usePredictableInterfaceNames = false;
        networking.interfaces.eth0.useDHCP = true;

        # ── Agenix ────────────────────────────────────────────────────
        age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
  };
}
