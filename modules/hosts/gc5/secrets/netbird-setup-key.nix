{ lib, ... }:
{
  den.aspects.gc5.nixos =
    { config, ... }:
    lib.mkIf (builtins.pathExists ./netbird-setup-key.age) {
      age.secrets."netbird-setup-key" = {
        file = ./netbird-setup-key.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      services.netbird.clients.default.login = {
        enable = true;
        setupKeyFile = config.age.secrets."netbird-setup-key".path;
      };
    };
}
