{ den, lib, ... }:
{
  # nixos2 — repo-managed VM at 10.178.76.45.
  # Existing in-place NixOS install converted to this flake configuration.
  den.aspects.nixos2 = {
    includes = [
      den.aspects.base-server
      den.aspects.impermanence
    ];

    nixos = {
      system.stateVersion = "25.11";

      # ── Hardware ──────────────────────────────────────────────────
      boot.initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "sd_mod"
        "ata_piix"
        "xen_blkfront"
        "vmw_pvscsi"
      ];
      boot.kernelModules = [ "kvm-amd" ];

      # ── Filesystems (impermanence without repartitioning) ────────
      # Reuse the existing root ext4 filesystem as /persist, keep / as tmpfs,
      # and bind-mount /persist/nix into /nix.
      fileSystems."/" = {
        fsType = "tmpfs";
        options = [
          "size=25%"
          "mode=755"
        ];
      };
      fileSystems."/persist" = {
        device = "/dev/disk/by-uuid/751e5394-8304-4531-87e3-4b6b0ae25b12";
        fsType = "ext4";
      };
      fileSystems."/nix" = {
        device = "/persist/nix";
        fsType = "none";
        options = [ "bind" ];
        neededForBoot = true;
      };
      fileSystems."/efi" = {
        device = "/dev/disk/by-uuid/40CE-3E87";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      # ── Bootloader ────────────────────────────────────────────────
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/efi";
      boot.kernelParams = [
        "console=ttyS0,115200n8"
        "console=tty0"
      ];
      boot.initrd.postDeviceCommands = lib.mkAfter ''
        mkdir -p /mnt-root/nix
      '';

      # ── Networking (systemd-networkd) ─────────────────────────────
      networking.usePredictableInterfaceNames = false;
      networking.useNetworkd = true;
      networking.useDHCP = false;
      networking.useHostResolvConf = false;
      networking.networkmanager.enable = lib.mkForce false;
      systemd.network.enable = true;
      services.resolved.enable = true;

      systemd.network.networks."10-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          DHCP = "yes";
          IPv6AcceptRA = true;
        };
        linkConfig.RequiredForOnline = true;
      };

      # ── Cache-first rebuilds on the host ──────────────────────────
      # Minimal compromise: allow a single local build job so Home Manager
      # can realize user profiles, while auto-upgrades stay cache-only.
      nix.settings = {
        fallback = false;
        max-jobs = 1;
      };

      system.autoUpgrade.flags = [
        "--option"
        "fallback"
        "false"
        "--option"
        "max-jobs"
        "0"
      ];

      environment.persistence."/persist" = {
        files = lib.mkForce [ "/etc/adjtime" ];
        directories = [ "/root" ];
      };
    };
  };
}
