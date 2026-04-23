{ inputs, ... }:
{
  # Shared impermanence aspect.
  # Hosts that include this get tmpfs root with persistent /persist.
  den.aspects.impermanence = {
    nixos =
      { ... }:
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

      };

    # Home-level persistence for all users on impermanence hosts.
    # This lives here (not in the user aspect) so it's only active
    # when the impermanence HM module is available.
    homeManager =
      { ... }:
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
