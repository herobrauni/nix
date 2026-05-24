{ den, lib, ... }:
{
  # oracle1 — Oracle Cloud ARM64 (aarch64) VM at 130.61.82.161.
  den.aspects.oracle1 = {
    includes = [
      den.aspects.base-server
      den.aspects.single-disk-efi-vps
      den.aspects.impermanence
      den.aspects.networkd-base
      den.aspects.beszel-agent
      den.aspects.tailscale
    ];

    nixos = {
      system.stateVersion = "25.11";

      # ── Hardware ──────────────────────────────────────────────────
      boot.initrd.availableKernelModules = [
        "ena"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "virtio_blk"
      ];

      # ── Impermanence ──────────────────────────────────────────────
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
        "console=ttyAMA0,115200n8"
        "console=tty0"
      ];

      environment.persistence."/persist".directories = [
        "/root"
        "/var/lib/beszel-agent"
      ];

      # ── Networking (DHCP behind NAT) ──────────────────────────────
      networking.usePredictableInterfaceNames = false;
      networking.networkmanager.enable = lib.mkForce false;

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig.DHCP = "yes";
        dhcpV4Config.RouteMTUBytes = 9000;
        linkConfig.RequiredForOnline = true;
      };
    };
  };
}
