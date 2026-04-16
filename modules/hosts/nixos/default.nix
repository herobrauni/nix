{ den, ... }:
{
  # nixos — this VM's in-place repo-managed configuration.
  den.aspects.nixos = {
    includes = [
      den.aspects.base-server
      den.aspects.networkd-base
    ];

    nixos =
      { modulesPath, ... }:
      {
        system.stateVersion = "25.11";

        imports = [
          "${modulesPath}/virtualisation/incus-virtual-machine.nix"
        ];

        networking.dhcpcd.enable = false;

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
