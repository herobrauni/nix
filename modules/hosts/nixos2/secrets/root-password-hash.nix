{ den, ... }:
{
  den.aspects.nixos2.nixos =
    { config, ... }:
    {
      age.secrets.root-password-hash = {
        file = ./root-password-hash.age;
        owner = "root";
        group = "root";
        mode = "0400";
      };

      users.mutableUsers = false;
      users.users.root.hashedPasswordFile = config.age.secrets.root-password-hash.path;
    };
}
