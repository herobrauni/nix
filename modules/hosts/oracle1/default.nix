{ den, inputs, lib, ... }:
{
  # oracle1 — Oracle Cloud ARM64 VPS at 130.61.82.161 (private 10.0.0.216).
  den.aspects.oracle1 = {
    includes = [
      den.aspects.base-server
      den.aspects.boot-limine-efi
      den.aspects.impermanence
      den.aspects.networkd-base
      den.aspects.netbird
      den.aspects.beszel-agent
    ];

    nixos = {
      imports = [ inputs.disko.nixosModules.disko ];

      system.stateVersion = "25.11";

      # ── Hardware ──────────────────────────────────────────────────
      boot.initrd.availableKernelModules = [
        "sd_mod"
        "sr_mod"
        "virtio_blk"
        "virtio_pci"
        "virtio_scsi"
        "vmw_pvscsi"
        "xen_blkfront"
      ];

      # ── Filesystems / bootloader ────────────────────────────────
      boot.loader.efi.efiSysMountPoint = "/boot";

      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              esp = {
                size = "512M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [ "umask=0077" ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                };
              };
            };
          };
        };
      };

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
      fileSystems."/boot".neededForBoot = true;
      fileSystems."/nix" = {
        device = "/persist/nix";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };

      boot.kernelParams = [
        "console=ttyAMA0"
      ];

      # ── Networking (systemd-networkd, DHCP behind NAT) ──────────
      networking.usePredictableInterfaceNames = false;
      networking.networkmanager.enable = lib.mkForce false;

      environment.persistence."/persist".directories = [
        "/root"
        "/var/lib/beszel-agent"
      ];

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "yes";
        };
        linkConfig.RequiredForOnline = true;
      };
    };
  };
}
