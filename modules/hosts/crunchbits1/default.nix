{ den, lib, ... }:
{
  # crunchbits1 — Crunchbits VPS at 104.36.84.254, adopted in-place from an existing NixOS install.
  den.aspects.crunchbits1 = {
    includes = [
      den.aspects.base-server
      den.aspects.boot-limine-bios
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
      # Reuse the existing ext4 root filesystem as /persist, keep / on tmpfs,
      # and bind-mount persistent subtrees back into place.
      #
      # This host is migrated in-place, but we switch the BIOS bootloader to
      # Limine as part of the same deployment.
      fileSystems."/" = lib.mkForce {
        fsType = "tmpfs";
        options = [
          "size=25%"
          "mode=755"
        ];
      };
      fileSystems."/persist" = {
        device = "/dev/disk/by-uuid/77eb803a-27dd-482f-a393-e4ff5ef8dcc4";
        fsType = "ext4";
      };
      fileSystems."/nix" = {
        device = "/persist/nix";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
      fileSystems."/boot" = {
        device = "/persist/boot";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };

      boot.loader.grub.enable = lib.mkForce false;
      boot.loader.limine.biosDevice = "/dev/vda";
      boot.kernelParams = [
        "console=ttyS0,115200n8"
        "console=tty0"
      ];
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        mkdir -p /mnt-root/nix /mnt-root/boot
      '';

      # ── Networking (systemd-networkd, static IPv4/IPv6) ──────────
      networking.usePredictableInterfaceNames = false;
      networking.networkmanager.enable = lib.mkForce false;

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
            GatewayOnLink = true;
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
