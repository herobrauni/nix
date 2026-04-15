{ lib, ... }:
{
  # Shared Limine bootloader defaults for EFI-based hosts.
  den.aspects.boot-limine-efi = {
    nixos = {
      boot.loader.limine = {
        enable = true;
        efiSupport = true;
      };
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
      boot.loader.timeout = lib.mkDefault 5;
    };
  };
}
