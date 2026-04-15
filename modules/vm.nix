{ inputs, den, ... }:
{
  den.aspects.nixos.includes = [ (den.provides.tty-autologin "brauni") ];

  perSystem =
    { pkgs, lib, ... }:
    {
      # Run any host in a VM: nix run .#vm -- nixos
      # Defaults to nixos if no argument is given.
      packages.vm = pkgs.writeShellApplication {
        name = "vm";
        text =
          let
            hosts = inputs.self.nixosConfigurations or { };
            # Build a helper script that can resolve any host dynamically
          in
          ''
            host="''${1:-nixos}"
            shift 2>/dev/null || true
            config="${inputs.self}#nixosConfigurations.$host.config"
            hostname=$(nix eval --raw "$config.networking.hostName")
            nix build "$config.system.build.vm" --no-link --print-out-paths \
              | xargs -I{} "{}/bin/run-$hostname-vm" "$@"
          '';
      };
    };
}
