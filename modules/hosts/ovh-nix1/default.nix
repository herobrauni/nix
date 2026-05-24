{ den, lib, ... }:
{
  # ovh-nix1 — OVH VPS.
  # eth0: NetBird tunnel (10.10.15.100, DHCP)
  # eth1: OVH public (IPv6 only via SLAAC)
  den.aspects.ovh-nix1 = {
    includes = [
      den.aspects.base-server
      den.aspects.single-disk-efi-vps
      den.aspects.impermanence
      den.aspects.networkd-base
      den.aspects.beszel-agent
      den.aspects.tailscale
      den.aspects.dev-tools
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

      # ── Networking (systemd-networkd) ────────────────────────────
      networking.usePredictableInterfaceNames = false;
      networking.networkmanager.enable = lib.mkForce false;

      environment.persistence."/persist".directories = [
        "/root"
        "/var/lib/beszel-agent"
      ];

      # eth0: NetBird tunnel — DHCP
      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = true;
          DNS = [
            "1.1.1.1"
            "8.8.8.8"
            "2606:4700:4700::1111"
            "2001:4860:4860::8888"
          ];
        };
        linkConfig.RequiredForOnline = true;
      };

      # eth1: OVH public — IPv6 via SLAAC
      systemd.network.networks."20-eth1" = {
        matchConfig.Name = "eth1";
        networkConfig = {
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = false;
      };
    };
  };
}
