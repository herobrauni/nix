{ den, ... }:
{
  # gigahost1 — VPS at 185.125.169.63, converted from a fresh reinstall.
  den.aspects.gigahost1 = {
    includes = [
      den.aspects.base-server
    ];

    nixos = {
      system.stateVersion = "25.11";

      # ── Hardware ──────────────────────────────────────────────────
      boot.initrd.availableKernelModules = [
        "ata_piix"
        "uhci_hcd"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "ahci"
        "xen_blkfront"
        "vmw_pvscsi"
      ];
      boot.kernelModules = [ "kvm-amd" ];

      # ── Filesystems (match existing install) ─────────────────────
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/295f1e7f-4e29-4230-be0b-22ddf6bdce78";
        fsType = "ext4";
      };

      # ── Bootloader ────────────────────────────────────────────────
      boot.loader.grub.enable = true;
      boot.loader.grub.device = "/dev/sda";
      boot.kernelParams = [ "console=tty0" ];

      # ── Networking (systemd-networkd, static IPv4/IPv6) ──────────
      networking.usePredictableInterfaceNames = false;
      networking.useNetworkd = true;
      networking.useDHCP = false;
      networking.useHostResolvConf = false;
      systemd.network.enable = true;
      services.resolved.enable = true;

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        address = [
          "185.125.169.63/24"
          "2a03:94e0:ffff:185:125:169:0:63/118"
        ];
        routes = [
          {
            Gateway = "185.125.169.1";
          }
          {
            Gateway = "2a03:94e0:ffff:185:125:169:0:1";
          }
        ];
        networkConfig = {
          DNS = [
            "1.1.1.1"
            "8.8.8.8"
            "2606:4700:4700::1111"
            "2001:4860:4860::8888"
          ];
          IPv6AcceptRA = false;
        };
        linkConfig.RequiredForOnline = true;
      };
    };
  };
}
