{
  lib,
  den,
  self,
  ...
}:
let
  configurationRevision = self.rev or self.dirtyRev or null;
in
{
  # Global defaults — can be overridden per-host.

  # homeManager class is enabled for all users
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Applied to all hosts, users, and homes.
  # - define-user: creates users.users.<name> on OS + home.username/home.homeDirectory in HM
  # - hostname: sets networking.hostName from host.hostName (auto-derived from host name)
  den.default = {
    nixos = {
      home-manager.backupFileExtension = "backup";
      home-manager.useUserPackages = true;
      system.configurationRevision = lib.mkDefault configurationRevision;
    };
    homeManager.home.stateVersion = "25.11";
    includes = [
      den._.define-user
      den._.hostname
    ];
  };

  # host <-> user mutual provider
  den.schema.user.includes = [ den._.mutual-provider ];
}
