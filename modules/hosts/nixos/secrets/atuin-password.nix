{ den, ... }:
{
  den.aspects.nixos.nixos.age.secrets.atuin-password = {
    file = ./atuin-password.age;
    owner = "brauni";
    mode = "0400";
  };
}
