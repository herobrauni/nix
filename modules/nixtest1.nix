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

        # ── Disk layout ──────────────────────────────────────────────
        disko.devices = {
          disk = {
            main = {
              type = "disk";
              # Change this to match your actual device (e.g. /dev/sda, /dev/vda)
              device = "/dev/vda";
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

        # ── Networking ───────────────────────────────────────────────
        networking.hostName = "nixtest1";

        # Use systemd-networkd for reliable server networking
        networking.useNetworkd = true;
        networking.useDHCP = false;
        systemd.network.enable = true;
        services.resolved.enable = true;

        # TODO: adjust to your actual interface name and IP config
        # Check with `ip link` on the Debian host before migrating.
        # This is a static example — replace with your actual network config.
        systemd.network.networks."10-eth0" = {
          matchConfig.Name = "eth0";
          address = [ "10.10.13.100/24" ];
          routes = [ { routeConfig.Gateway = "10.10.13.1"; } ];
          linkConfig.RequiredForOnline = true;
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
