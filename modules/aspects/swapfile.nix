{ lib, ... }:
{
  # Swap file on /persist for low-RAM VPS hosts.
  # Prevents OOM kills during nix evaluation in auto-upgrade.
  #
  # Usage:
  #   den.aspects.myhost.includes = [ den.aspects.swapfile ];
  #
  # To override the default size (2 GiB), set in the host's nixos config:
  #   swapDevices = lib.mkForce [ { device = "/persist/swapfile"; size = 4096; } ];
  den.aspects.swapfile = {
    nixos = {
      swapDevices = [
        {
          device = "/persist/swapfile";
          size = 2048; # MiB (2 GiB)
        }
      ];
    };
  };
}
