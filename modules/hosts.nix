{
  # nixtest1 - test host, currently Debian to be migrated
  den.hosts.x86_64-linux.nixtest1.users.brauni = { };
  den.hosts.x86_64-linux.nixtest2.users.brauni = { };
  den.hosts.x86_64-linux.nixos2 = {
    aspect = "nixos2";
    hostName = "nixos2";
    users.brauni = { };
  };
  den.hosts.x86_64-linux.nixosvm = {
    aspect = "nixosvm";
    hostName = "nixos";
    users.brauni = { };
  };
}
