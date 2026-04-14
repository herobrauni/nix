{ inputs, den, ... }:
{
  # Shared agenix aspect.
  # All hosts get the agenix NixOS module and decrypt with the host SSH key.
  den.aspects.base-server.includes = [ den.aspects.agenix ];

  den.aspects.agenix = {
    nixos = {
      imports = [ inputs.agenix.nixosModules.default ];

      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    };
  };
}
