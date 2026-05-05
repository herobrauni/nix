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
        accept-flake-config = true;

        # Avoid stale cache misses when a host checks for a new generation before
        # CI has finished pushing that generation to Niks3.
        narinfo-cache-negative-ttl = 0;

        # Never build locally — always pull from substituters.
        # This avoids OOM on small VPS hosts during nh os switch.
        max-jobs = 0;

        # NixOS generates several host-specific trivial derivations with
        # allowSubstitutes = false / preferLocalBuild = true. CI still pushes
        # them to Niks3, so force Nix to accept substitutes for them instead of
        # trying (and failing) to build with max-jobs = 0.
        always-allow-substitutes = true;

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
          "https://niks3.brauni.dev"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "SIGNING_KEY:L2S1rOofwctOTq+ygU/myKHJGhuL2qu/hzAOD1q2SG4="
        ];
      };
    };
  };
}
