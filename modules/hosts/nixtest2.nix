{ inputs, den, ... }:
{
  # nixtest2 — converted existing NixOS install (no disko, no impermanence).
  # Disk: /dev/sda1=vfat(/efi 100M), /dev/sda2=ext4(/ 14.9G), /swapfile 77M
  # Intentionally no disko config — this was an in-place conversion,
  # so filesystems are referenced by UUID from the original install.
  den.aspects.nixtest2 = {
    includes = [
      den.aspects.base-server
    ];

    nixos =
      { pkgs, lib, ... }:
      {
        system.stateVersion = "25.11";

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

        # ── Swap (zram only, handled by base-server aspect) ───────

        # ── Bootloader (limine) ──────────────────────────────────────
        boot.loader.limine = {
          enable = true;
          efiSupport = true;
        };
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.efi.efiSysMountPoint = "/efi";
        boot.loader.timeout = 5;
        boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];

        # ── Networking (systemd-networkd, consistent with other hosts) ─
        # hostname is set automatically by den._.hostname from host.hostName
        networking.usePredictableInterfaceNames = false;
        networking.useNetworkd = true;
        networking.useDHCP = false;
        systemd.network.enable = true;
        services.resolved.enable = true;

        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.DHCP = "yes";
          linkConfig.RequiredForOnline = true;
        };

        # ── Agenix ────────────────────────────────────────────────────
        age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        age.secrets.atuin-password = {
          file = ../../secrets/atuin-password.age;
          owner = "brauni";
        };
      };
  };
}
