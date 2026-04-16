{ lib, ... }:
{
  # Shared systemd-networkd + resolved baseline for server-style hosts.
  # Hosts still provide interface-specific addresses/routes.
  den.aspects.networkd-base = {
    nixos = {
      networking = {
        useNetworkd = true;
        useDHCP = false;
        useHostResolvConf = false;
      };

      systemd.network.enable = true;
      services.resolved.enable = true;

      # Server hosts in this repo use networkd instead of NetworkManager.
      networking.networkmanager.enable = lib.mkDefault false;
    };
  };
}
