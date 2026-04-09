{ inputs, ... }:
{
  # Shared impermanence aspect.
  # Hosts that include this get tmpfs root with persistent /persist.
  den.aspects.impermanence = {
    nixos =
      { pkgs, ... }:
      {
        imports = [ inputs.impermanence.nixosModules.impermanence ];

        # Needed early in boot for impermanence bind-mounts to work
        fileSystems."/persist".neededForBoot = true;

        environment.persistence."/persist" = {
          hideMounts = true;
          directories = [
            "/var/log"
            "/var/lib/nixos"
            "/var/lib/systemd"
            "/etc/ssh"
          ];
          files = [
            "/etc/machine-id"
          ];
        };

        # Create mountpoints early so systemd doesn't complain
        boot.initrd.postDeviceCommands = ''
          mkdir -p /mnt-root/persist
        '';
      };
  };
}
