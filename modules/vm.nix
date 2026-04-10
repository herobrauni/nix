{ inputs, den, ... }:
{
  den.aspects.nixtest1.includes = [ (den.provides.tty-autologin "brauni") ];

  perSystem =
    { pkgs, lib, ... }:
    {
      # Run any host in a VM: nix run .#vm -- nixtest1
      # Defaults to nixtest1 if no argument is given.
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            hosts = inputs.self.nixosConfigurations or { };
            # Build a helper script that can resolve any host dynamically
          in
          ''
            host="''${1:-nixtest1}"
            shift 2>/dev/null || true
            config="${inputs.self}#nixosConfigurations.$host.config"
            hostname=$(nix eval --raw "$config.networking.hostName")
            nix build "$config.system.build.vm" --no-link --print-out-paths \
              | xargs -I{} "{}/bin/run-$hostname-vm" "$@"
          '';
      };
    };
}
