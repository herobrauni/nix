{ den, ... }:
{
  # gigahost1 — VPS at 185.125.169.63, converted from a fresh reinstall.
  den.aspects.gigahost1 = {
    includes = [
      den.aspects.base-server
      den.aspects.single-disk-bios-vps
      den.aspects.networkd-base
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

      # ── Disk layout / bootloader come from single-disk-bios-vps ──
      boot.kernelParams = [ "console=tty0" ];

      # ── Networking (systemd-networkd, static IPv4/IPv6) ──────────
      networking.usePredictableInterfaceNames = false;

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
