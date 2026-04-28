{ den, lib, ... }:
{
  # axushost1 — Axus VPS at 185.222.160.23.
  den.aspects.axushost1 = {
    includes = [
      den.aspects.base-server
      den.aspects.single-disk-bios-vps
      den.aspects.impermanence
      den.aspects.networkd-base
      den.aspects.netbird
      den.aspects.beszel-agent
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
        "virtio_blk"
      ];
      boot.kernelModules = [ "kvm-intel" ];

      # ── Filesystems / bootloader ────────────────────────────────
      fileSystems."/" = lib.mkForce {
        fsType = "tmpfs";
        options = [
          "size=25%"
          "mode=755"
        ];
      };
      fileSystems."/persist" = {
        device = "/dev/disk/by-partlabel/disk-main-root";
        fsType = "ext4";
      };
      fileSystems."/nix" = {
        device = "/persist/nix";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };

      boot.kernelParams = [
        "console=ttyS0,115200n8"
        "console=tty0"
      ];

      # ── Networking (systemd-networkd, static IPv4) ──────────────
      networking.usePredictableInterfaceNames = false;
      networking.networkmanager.enable = lib.mkForce false;

      environment.persistence."/persist".directories = [
        "/root"
        "/var/lib/beszel-agent"
      ];

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        address = [
          "185.222.160.23/24"
        ];
        routes = [
          {
            Gateway = "185.222.160.1";
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
