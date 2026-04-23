{
  den.hosts.x86_64-linux.nixos = {
    aspect = "nixos";
    hostName = "nixos";
    users.brauni = { };
  };
  den.hosts.x86_64-linux.gigahost1 = {
    aspect = "gigahost1";
    hostName = "gigahost1";
    singleDisk.device = "/dev/sda";
    users.brauni = { };
  };
  den.hosts.x86_64-linux.crunchbits1 = {
    aspect = "crunchbits1";
    hostName = "crunchbits1";
    users.brauni = { };
  };
  den.hosts.x86_64-linux.gc5 = {
    aspect = "gc5";
    hostName = "gc5";
    singleDisk.device = "/dev/vda";
    users.brauni = { };
  };
  den.hosts.x86_64-linux.nixos2 = {
    aspect = "nixos2";
    hostName = "nixos2";
    users.brauni = { };
  };
}
