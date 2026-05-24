{ lib, ... }:
{
  # Shared Tailscale client aspect.
  # All hosts join the tailnet as exit nodes.
  #
  # Requires a tailscale-auth-key agenix secret (see agenix.nix).
  # Generate an auth key at: https://login.tailscale.com/admin/settings/keys
  # Then create the secret:
  #   cd /path/to/repo && agenix -e secrets/shared/tailscale-auth-key.age
  den.aspects.tailscale.nixos =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.tailscale = {
        enable = true;
        # "server" enables IP forwarding and loose reverse path filtering
        # required for exit node functionality.
        useRoutingFeatures = "server";
        # Advertise this node as an exit node on the tailnet.
        # The exit node must still be approved in the admin console.
        extraUpFlags = [
          "--advertise-exit-node"
          "--ssh"
          "--accept-routes"
          "--accept-dns"
        ];
        authKeyFile = config.age.secrets."tailscale-auth-key".path;
      };

      # Tailscale auth key login runs at boot. Ensure network is ready.
      systemd.services.tailscaled.after = [ "network-online.target" ];
      systemd.services.tailscaled.wants = [ "network-online.target" ];
    };
}
