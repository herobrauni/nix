{ inputs, den, lib, ... }:
{
  den.aspects.nixtest1 = {
    includes = [
      den.aspects.base-server
      den.aspects.impermanence
    ];

    nixos =
      { pkgs, ... }:
      {
        imports = [
          inputs.disko.nixosModules.disko
          inputs.agenix.nixosModules.default
        ];

        # ── Disk layout (OVH VPS: /dev/sda, 15G) ──────────────────────
        disko.devices = {
          disk = {
            main = {
              type = "disk";
              device = "/dev/sda";
              content = {
                type = "gpt";
                partitions = {
                  esp = {
                    size = "512M";
                    type = "EF00";
                    content = {
                      type = "filesystem";
                      format = "vfat";
                      mountpoint = "/boot";
                      mountOptions = [ "umask=0077" ];
                    };
                  };
                  persist = {
                    size = "100%";
                    content = {
                      type = "filesystem";
                      format = "ext4";
                      mountpoint = "/persist";
                    };
                  };
                };
              };
            };
          };
          nodev = {
            "/" = {
              fsType = "tmpfs";
              mountOptions = [
                "size=25%"
                "mode=755"
              ];
            };
          };
        };

        # ── Networking (OVH: eth0=private DHCP, eth1=public IPv6) ─────
        networking.hostName = "nixtest1";

        networking.useNetworkd = true;
        networking.useDHCP = false;
        systemd.network.enable = true;
        services.resolved.enable = true;

        # eth0: private network (10.10.13.0/24) via DHCP
        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          networkConfig.DHCP = "yes";
          dhcpV4Config.RouteMetric = 100;
          linkConfig.RequiredForOnline = true;
        };

        # eth1: public IPv6 via DHCP6
        systemd.network.networks."20-eth1" = {
          matchConfig.Name = "eth1";
          networkConfig.DHCP = "yes";
          dhcpV6Config = {
            PrefixDelegationHint = "auto";
          };
          networkConfig.IPv6AcceptRA = true;
          linkConfig.RequiredForOnline = false;
        };

        # ── Bootloader ───────────────────────────────────────────────
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # ── Agenix ───────────────────────────────────────────────────
        age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

        # ── Host-specific packages ───────────────────────────────────
        environment.systemPackages = with pkgs; [
          curl
          wget
        ];
      };
  };
}
