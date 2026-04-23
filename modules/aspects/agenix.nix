{
  inputs,
  den,
  lib,
  ...
}:
{
  # Shared agenix aspect.
  # All hosts get the agenix NixOS module and decrypt with the host SSH key.
  den.aspects.base-server.includes = [ den.aspects.agenix ];

  den.aspects.agenix = {
    nixos = {
      imports = [ inputs.agenix.nixosModules.default ];

      age = {
        identityPaths = [
          "/persist/etc/ssh/ssh_host_ed25519_key"
          "/persist/etc/ssh/ssh_host_rsa_key"
        ];

        secrets =
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
          });
      };
    };
  };
}
