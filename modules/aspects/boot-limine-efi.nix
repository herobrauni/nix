{ inputs, den, lib, ... }:
{
  # Shared Limine bootloader defaults for EFI-based hosts.
  den.aspects.boot-limine-efi = {
    nixos = {
      boot.loader.limine = {
        enable = true;
        efiSupport = true;
      };
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault false;
      boot.loader.timeout = lib.mkDefault 5;
    };
  };

  # Shared destructive disko layout for EFI VPSes with a single disk.
  # Hosts opt in by setting `singleDisk.device` in `modules/hosts.nix`.
  # The ESP is 1GB to accommodate ARM64 kernel images (~64MB each).
  den.aspects.single-disk-efi-vps = den.lib.perHost (
    { host, ... }:
    {
      includes = [ den.aspects.boot-limine-efi ];

      nixos = {
        imports = [ inputs.disko.nixosModules.disko ];

        assertions = [
          {
            assertion = host.singleDisk.device != null;
            message = "Host ${host.name} includes den.aspects.single-disk-efi-vps but does not set singleDisk.device.";
          }
        ];

        disko.devices = {
          disk.main = {
            type = "disk";
            device = host.singleDisk.device;
            content = {
              type = "gpt";
              partitions = {
                esp = {
                  size = "1G";
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
      };
    }
  );
}
