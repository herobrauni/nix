{
  den,
  inputs,
  lib,
  ...
}:
{
  # hostc5 — IPv6-only Host-C VPS at 2a0d:8144:0:14f::.
  den.aspects.hostc5 = {
    includes = [
      den.aspects.base-server
      den.aspects.boot-limine-bios
      den.aspects.impermanence
      den.aspects.networkd-base
      den.aspects.github-ipv6-proxy
      den.aspects.beszel-agent
      den.aspects.tailscale
      # den.aspects.netbird
      den.aspects.swapfile
    ];

    nixos = {
      imports = [ inputs.disko.nixosModules.disko ];

      system.stateVersion = "25.11";

      # ── Hardware ──────────────────────────────────────────────────
      boot.initrd.availableKernelModules = [
        "ahci"
        "ata_piix"
        "sd_mod"
        "sr_mod"
        "uhci_hcd"
        "virtio_blk"
        "virtio_pci"
        "virtio_scsi"
        "vmw_pvscsi"
        "xen_blkfront"
      ];
      boot.kernelModules = [ "kvm-intel" ];

      # ── Filesystems / bootloader ────────────────────────────────
      boot.loader.limine = {
        biosDevice = "/dev/sda";
        partitionIndex = 1;
      };

      disko.devices = {
        disk.main = {
          type = "disk";
          device = "/dev/sda";
          content = {
            type = "gpt";
            partitions = {
              bios = {
                size = "4M";
                type = "EF02";
              };
              boot = {
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
        "console=ttyS0,115200n8"
        "console=tty0"
      ];

      # ── Networking (systemd-networkd, static IPv6-only) ──────────
      networking.usePredictableInterfaceNames = false;
      networking.networkmanager.enable = lib.mkForce false;

      environment.persistence."/persist".directories = [
        "/root"
        "/var/lib/beszel-agent"
      ];

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        address = [ "2a0d:8144:0:14f::/64" ];
        routes = [
          {
            Gateway = "2a0d:8144::1";
            GatewayOnLink = true;
          }
        ];
        networkConfig = {
          DNS = [
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
