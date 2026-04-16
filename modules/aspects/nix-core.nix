{ ... }:
{
  # Shared Nix daemon and binary cache policy.
  den.aspects.nix-core = {
    nixos = {
      nix.settings = {
        auto-optimise-store = true;
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
