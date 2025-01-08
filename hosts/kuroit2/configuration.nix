{
  config,
  system,
  ...
}: {
  system = config.system;
  networking.hostName = config.hostName;
  imports = [
    ../../modules/base/server.nix
    ../../modules/users/brauni.nix
    ./hardware-configuration.nix
  ];
}
