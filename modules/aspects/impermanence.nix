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
            "/var/lib/acme"
            "/etc/ssh"
            # Full home directory persistence
            "/home/brauni"
          ];
          files = [
            "/etc/machine-id"
          ];
        };

        # home-manager activation runs as root and can create files/dirs
        # owned by root inside the user's home on /persist. This service
        # runs early in boot after the persistent filesystem is mounted,
        # recursively fixing ownership before user sessions start.
        systemd.services."impermanence-fix-home-perms" = {
          description = "Fix brauni home directory permissions on persistent storage";
          after = [ "local-fs.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.coreutils}/bin/chown -R brauni:users /persist/home/brauni";
            RemainAfterExit = true;
          };
        };

      };

    # Home-level persistence for all users on impermanence hosts.
    # This lives here (not in the user aspect) so it's only active
    # when the impermanence HM module is available.
    homeManager =
      { ... }:
      {
        # Full home directory persistence is handled at the OS level
        # via /home/brauni in the environment.persistence block above.
        # No separate home.persistence needed since the entire home is bind-mounted.
      };
  };
}
