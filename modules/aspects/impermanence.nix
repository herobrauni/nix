{ inputs, lib, ... }:
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
            "/var/lib/acme"
            "/etc/ssh"
          ];
          files = [
            "/etc/machine-id"
          ];
        };

        # Create mountpoints early so systemd and impermanence units don't fail.
        boot.initrd.postDeviceCommands = lib.mkAfter ''
          mkdir -p /mnt-root/persist /mnt-root/persist/etc
        '';
      };

    # Home-level persistence for all users on impermanence hosts.
    # This lives here (not in the user aspect) so it's only active
    # when the impermanence HM module is available.
    homeManager =
      { pkgs, ... }:
      {
        home.persistence."/persist/home" = {
          directories = [
            ".ssh"
            ".config"
            ".local/share"
            ".cache"
          ];
          files = [
            ".bash_history"
          ];
        };
      };
  };
}
