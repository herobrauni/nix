{
  inputs,
  den,
  lib,
  ...
}:
{
  den.schema.host.options.agenix.sharedSecrets.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether to install shared agenix secrets on this host. Disable this for
      brand-new hosts until their SSH host key has been added to secrets.nix
      and the shared secrets have been rekeyed.
    '';
  };

  # Shared agenix aspect.
  # All hosts get the agenix NixOS module and decrypt with the host SSH key.
  den.aspects.base-server.includes = [ den.aspects.agenix ];

  den.aspects.agenix = den.lib.perHost (
    { host, ... }:
    {
      nixos = {
        imports = [ inputs.agenix.nixosModules.default ];

        age = {
          identityPaths = [
            "/persist/etc/ssh/ssh_host_ed25519_key"
            "/persist/etc/ssh/ssh_host_rsa_key"
          ];

          secrets = lib.optionalAttrs host.agenix.sharedSecrets.enable (
            (lib.optionalAttrs (builtins.pathExists ../../secrets/shared/atuin-password.age) {
              "atuin-password" = {
                file = ../../secrets/shared/atuin-password.age;
                owner = "brauni";
                mode = "0400";
              };
            })
            // (lib.optionalAttrs (builtins.pathExists ../../secrets/shared/atuin-key.age) {
              "atuin-key" = {
                file = ../../secrets/shared/atuin-key.age;
                owner = "brauni";
                mode = "0400";
              };
            })
            // (lib.optionalAttrs (builtins.pathExists ../../secrets/shared/beszel.age) {
              beszel = {
                file = ../../secrets/shared/beszel.age;
                owner = "root";
                group = "root";
                mode = "0400";
              };
            })
            // (lib.optionalAttrs (builtins.pathExists ../../secrets/shared/netbird-setup-key.age) {
              "netbird-setup-key" = {
                file = ../../secrets/shared/netbird-setup-key.age;
                owner = "root";
                group = "root";
                mode = "0400";
              };
            })
          );
        };
      };
    }
  );
}
