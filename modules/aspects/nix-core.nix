{ ... }:
{
  # Shared Nix daemon, binary cache policy, and Nix CLI helpers.
  den.aspects.nix-core = {
    nixos = {
      programs.nh = {
        enable = true;
        flake = "github:herobrauni/nix";
      };

      nix.settings = {
        auto-optimise-store = true;

        # Never build locally — always pull from substituters.
        # This avoids OOM on small VPS hosts during nh os switch.
        max-jobs = 0;

        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "root"
          "@wheel"
        ];
        substituters = [
          "https://cache.nixos.org"
          "https://brauni.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "brauni.cachix.org-1:AK1gTT3vQZQh2OqWS4rh+DjV9lOlqa834O5pssx2rUw="
        ];
      };
    };
  };
}
