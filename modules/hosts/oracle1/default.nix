{ den, lib, ... }:
{
  # oracle1 — Oracle Cloud ARM64 at 130.61.82.161 (private 10.0.0.216).
  # In-place conversion from generic NixOS — existing partitions reused.
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
      system.stateVersion = "25.11";

      # ── Bootloader ──────────────────────────────────────────────
      # Existing ESP at /efi (Oracle Cloud default).
      boot.loader.efi.efiSysMountPoint = "/efi";

      # ── Filesystems (in-place impermanence) ─────────────────────
      # Reuse existing ext4 root as /persist, keep / on tmpfs.
      fileSystems."/" = lib.mkForce {
        fsType = "tmpfs";
        options = [
          "size=25%"
          "mode=755"
        ];
      };
      fileSystems."/persist" = {
        device = "/dev/disk/by-uuid/b0d382ae-5d9c-43c6-ba31-9da10a7d9797";
        fsType = "ext4";
      };
      fileSystems."/nix" = {
        device = "/persist/nix";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };

      boot.kernelParams = [
        "console=ttyAMA0"
      ];

      # ── Networking (DHCP behind NAT) ────────────────────────────
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
        dhcpV4Config.RouteMTUBytes = 9000;
        linkConfig.RequiredForOnline = true;
      };
    };
  };
}
