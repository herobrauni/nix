{
  inputs,
  den,
  lib,
  ...
}:
{
  den.schema.host = {
    options.singleDisk.device = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      example = "/dev/sda";
      description = "Install target for the shared single-disk BIOS VPS layout.";
    };
  };

  # Shared Limine bootloader defaults for BIOS-based hosts.
  den.aspects.boot-limine-bios = {
    nixos = {
      # nixpkgs-unstable is currently on Limine 11.4.0, which has a known
      # legacy BIOS regression that can stop boot with "limine integrity error".
      # Keep BIOS hosts on at least 11.4.1 until the input catches up.
      nixpkgs.overlays = [
        (final: prev: {
          limine =
            if lib.versionOlder prev.limine.version "11.4.1" then
              prev.limine.overrideAttrs (_old: {
                version = "11.4.1";
                src = final.fetchurl {
                  url = "https://github.com/Limine-Bootloader/Limine/releases/download/v11.4.1/limine-11.4.1.tar.gz";
                  hash = "sha256-sTmjVVhOb2EOhohW/SMJgrM8HT5t6afq1ekv+6eZNuY=";
                };
              })
            else
              prev.limine;
        })
      ];

      boot.loader.limine = {
        enable = true;
        efiSupport = false;
        biosSupport = true;
      };
      boot.loader.timeout = lib.mkDefault 5;
    };
  };

  # Shared destructive disko layout for BIOS VPSes with a single disk.
  # Hosts opt in by setting `singleDisk.device` in `modules/hosts.nix`.
  den.aspects.single-disk-bios-vps = den.lib.perHost (
    { host, ... }:
    {
      includes = [ den.aspects.boot-limine-bios ];

      nixos = {
        imports = [ inputs.disko.nixosModules.disko ];

        assertions = [
          {
            assertion = host.singleDisk.device != null;
            message = "Host ${host.name} includes den.aspects.single-disk-bios-vps but does not set singleDisk.device.";
          }
        ];

        disko.devices = {
          disk.main = {
            type = "disk";
            device = host.singleDisk.device;
            content = {
              type = "gpt";
              partitions = {
                bios = {
                  size = "1M";
                  type = "EF02";
                  attributes = [ 0 ];
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

        boot.loader.limine.biosDevice = host.singleDisk.device;
        boot.loader.limine.partitionIndex = 1;
      };
    }
  );
}
