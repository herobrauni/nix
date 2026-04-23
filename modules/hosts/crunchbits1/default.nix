{ den, lib, ... }:
{
  # crunchbits1 — Crunchbits VPS at 104.36.84.254, converted from a fresh reinstall.
  den.aspects.crunchbits1 = {
    includes = [
      den.aspects.base-server
      den.aspects.agenix
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
        "ahci"
        "virtio_pci"
        "virtio_scsi"
        "xhci_pci"
        "sd_mod"
        "sr_mod"
        "virtio_blk"
        "ata_piix"
        "xen_blkfront"
        "vmw_pvscsi"
      ];
      boot.kernelModules = [ "kvm-amd" ];

      # ── Filesystems / bootloader ────────────────────────────────
      # Reuse the single ext4 partition as /persist, keep / on tmpfs,
      # and bind-mount /persist/nix into /nix.
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

      boot.kernelParams = [ "console=tty0" ];
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        mkdir -p /mnt-root/nix
      '';

      # ── Networking (systemd-networkd, static IPv4/IPv6) ──────────
      networking.usePredictableInterfaceNames = false;

      environment.persistence."/persist".directories = [
        "/root"

        # Beszel keeps its fingerprint / credentials state under /var/lib/beszel-agent.
        # Reuse the pre-impermanence state from the old root now mounted at /persist.
        "/var/lib/beszel-agent"
      ];

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        address = [
          "104.36.84.254/22"
          "2606:a8c0:3:87::a/64"
        ];
        routes = [
          {
            Gateway = "104.36.84.1";
          }
          {
            Gateway = "2606:a8c0:3::1";
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
