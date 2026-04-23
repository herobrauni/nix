{ den, lib, ... }:
{
  den.aspects.crunchbits1.nixos = lib.mkIf (builtins.pathExists ./beszel.age) {
    age.secrets.beszel = {
      file = ./beszel.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };
}
