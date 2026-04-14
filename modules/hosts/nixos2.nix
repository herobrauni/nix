{ den, ... }:
{
  # nixos2 — repo-managed VM at 10.178.76.45.
  # Existing in-place NixOS install converted to this flake configuration.
  den.aspects.nixos2 = {
    includes = [
      den.aspects.base-server
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

      # ── Filesystems (match existing install) ─────────────────────
      fileSystems."/" = {
        device = "/dev/disk/by-uuid/751e5394-8304-4531-87e3-4b6b0ae25b12";
        fsType = "ext4";
      };
      fileSystems."/efi" = {
        device = "/dev/disk/by-uuid/40CE-3E87";
        fsType = "vfat";
        options = [ "fmask=0077" "dmask=0077" ];
      };

      # ── Bootloader ────────────────────────────────────────────────
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.loader.efi.efiSysMountPoint = "/efi";
      boot.kernelParams = [ "console=ttyS0,115200n8" "console=tty0" ];

      # ── Networking (keep the VM's working DHCP setup) ─────────────
      # systemd-networkd changed the DHCP lease from .45 to .46 on first
      # switch, which made the VM appear unreachable. Keep the existing
      # NetworkManager-based DHCP setup for this host.
      networking.usePredictableInterfaceNames = false;
      networking.interfaces.eth0.useDHCP = true;
      networking.networkmanager.enable = true;

      # ── Cache-only rebuilds on the host ───────────────────────────
      nix.settings = {
        fallback = false;
        max-jobs = 0;
      };

      system.autoUpgrade.flags = [
        "--option" "fallback" "false"
        "--option" "max-jobs" "0"
      ];
    };
  };
}
