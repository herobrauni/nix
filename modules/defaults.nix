{ lib, den, ... }:
{
  den.default.nixos.system.stateVersion = "25.11";
  den.default.homeManager.home.stateVersion = "25.11";

  # enable homeManager class for all users
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # host <-> user mutual provider
  den.ctx.user.includes = [ den._.mutual-provider ];
}
