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
      }

      (lib.optionalAttrs (options.environment ? persistence) {
        environment.persistence."/persist".directories = [ "/var/lib/netbird" ];
      })
    ];
}
