{ lib, ... }:
{
  # Shared Limine bootloader defaults for BIOS-based hosts.
  den.aspects.boot-limine-bios = {
    nixos = {
      boot.loader.limine = {
        enable = true;
        efiSupport = false;
        biosSupport = true;
      };
      boot.loader.timeout = lib.mkDefault 5;
    };
  };
}
