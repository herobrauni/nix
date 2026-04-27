{ lib, ... }:
{
  den.aspects.alpha1.nixos = lib.mkIf (builtins.pathExists ./beszel.age) {
    age.secrets.beszel = {
      file = ./beszel.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
