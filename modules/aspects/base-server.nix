{ den, ... }:
{
  # Shared base-server aspect.
  # All servers include this composition of smaller reusable aspects.
  den.aspects.base-server = {
    includes = [
      den.aspects.server-core
      den.aspects.ops-tools
      den.aspects.nix-core
      den.aspects.maintenance
    ];
  };
}
