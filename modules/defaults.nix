{ lib, den, ... }:
{
  # Global defaults — can be overridden per-host.

  # homeManager class is enabled for all users
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Applied to all hosts, users, and homes.
  # - define-user: creates users.users.<name> on OS + home.username/home.homeDirectory in HM
  # - hostname: sets networking.hostName from host.hostName (auto-derived from host name)
  den.default = {
    homeManager.home.stateVersion = "25.11";
    includes = [
      den._.define-user
      den._.hostname
    ];
  };

  # host <-> user mutual provider
  den.ctx.user.includes = [ den._.mutual-provider ];
}
