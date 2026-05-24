{ lib, ... }:
{
  # Shared NetBird client aspect.
  den.aspects.netbird.nixos =
    {
      config,
      options,
      pkgs,
      ...
    }:
    lib.mkMerge [
      {
        services.netbird.enable = true;
        services.netbird.clients.default = {
          config.ServerSSHAllowed = true;
          login = {
            enable = true;
            setupKeyFile = config.age.secrets."netbird-setup-key".path;
          };
        };

        # NetBird SSH shells call exec.LookPath("login") from the daemon.
        # NixOS service PATHs do not include login by default; see:
        # https://github.com/NixOS/nixpkgs/issues/505846
        systemd.services.${config.services.netbird.clients.default.service.name}.path = [ pkgs.shadow ];

        # The login service runs netbird up --setup-key at boot.
        # Without network-online.target, DNS may not be available yet,
        # causing the login to fail silently on first boot.
        systemd.services."netbird-login" = {
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
        };
      }

      (lib.optionalAttrs (options.environment ? persistence) {
        environment.persistence."/persist".directories = [ "/var/lib/netbird" ];
      })
    ];
}
