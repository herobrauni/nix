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
      { config, lib, ... }:
      {
        # Clean up HM-managed files from the persistent store before activation,
        # so changes to config.fish, atuin.toml, etc. don't cause "would be clobbered".
        home.activation.removeStaleConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] (
          let
            inherit (config.home) homeDirectory;
          in
          ''
            # Remove files that HM manages and that would conflict with fresh symlinks.
            for f in fish/config.fish atuin/config.toml; do
              rm -f "${homeDirectory}/.config/$f"
            done
          ''
        );

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
