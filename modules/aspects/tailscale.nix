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

      # Persist node identity across reboots (impermanence).
      # The bind mount must be active *before* tailscaled starts, otherwise
      # the StateDirectory on tmpfs is used and the node re-registers.
      environment.persistence."/persist".directories = [
        "/var/lib/tailscale"
      ];

      # Tailscale auth key login runs at boot. Ensure network is ready AND
      # the persistent state directory is mounted before tailscale starts.
      systemd.services.tailscaled = {
        after = [
          "network-online.target"
          "var-lib-tailscale.mount"
        ];
        wants = [ "network-online.target" ];
        requires = [ "var-lib-tailscale.mount" ];
      };

      # tailscaled-autoconnect runs "tailscale up --auth-key=…" and will
      # register a new node if the state isn't available yet.
      systemd.services.tailscaled-autoconnect = {
        after = [ "var-lib-tailscale.mount" ];
        requires = [ "var-lib-tailscale.mount" ];
      };
    };
}
