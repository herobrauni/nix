{ inputs, den, ... }:
{
  den.aspects.nixtest1.includes = [ (den.provides.tty-autologin "brauni") ];

  perSystem =
    { pkgs, ... }:
    {
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            host = inputs.self.nixosConfigurations.nixtest1.config;
          in
          ''
            ${host.system.build.vm}/bin/run-${host.networking.hostName}-vm "$@"
          '';
      };
    };
}
