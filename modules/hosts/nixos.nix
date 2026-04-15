{ den, ... }:
{
  # nixos — this VM's in-place repo-managed configuration.
  den.aspects.nixos = {
    includes = [
      den.aspects.base-server
    ];

    nixos =
      { modulesPath, ... }:
      {
        system.stateVersion = "25.11";

        imports = [
          "${modulesPath}/virtualisation/incus-virtual-machine.nix"
        ];

        networking = {
          dhcpcd.enable = false;
          useDHCP = false;
          useHostResolvConf = false;
        };

        services.resolved.enable = true;
        systemd.network.enable = true;

        systemd.network.networks."50-enp5s0" = {
          matchConfig.Name = "enp5s0";
          networkConfig = {
            DHCP = "yes";
            IPv6AcceptRA = true;
          };
          linkConfig.RequiredForOnline = "routable";
        };
      };
  };
}
