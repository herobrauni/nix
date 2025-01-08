{
  config,
  system,
  ...
}: {
  imports = [
    ../../modules/base/server.nix
    ./hardware-configuration.nix
    ./disko.nix
  ];
}
