{ lib, ... }:
{
  # Shared NetBird client aspect.
  den.aspects.netbird.nixos =
    { options, ... }:
    lib.mkMerge [
      {
        services.netbird.enable = true;
      }

      (lib.optionalAttrs (options.environment ? persistence) {
        environment.persistence."/persist".directories = [ "/var/lib/netbird" ];
      })
    ];
}
