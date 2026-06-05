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

        # Don't keep .drv files as GC roots – they drag in sources/patches
        # that are only needed at build time, wasting disk on small VPS hosts.
        keep-derivations = false;

        # Abort builds when the store filesystem drops below 1 GiB free.
        # Prevents nix from completely filling the disk during autoUpgrade.
        min-free = 1 * 1024 * 1024 * 1024;

        # Avoid stale cache misses when a host checks for a new generation before
        # CI has finished pushing that generation to Niks3.
        narinfo-cache-negative-ttl = 0;

        # Prefer substitutes from cache, but allow a single small local build as
        # a fallback. This keeps VPS memory pressure low while avoiding hard
        # failures when Nix has to realise tiny activation/profile derivations.
        max-jobs = 1;
        cores = 1;

        # NixOS generates several host-specific trivial derivations with
        # allowSubstitutes = false / preferLocalBuild = true. CI still pushes
        # them to Niks3, so force Nix to check substitutes for them before
        # falling back to the one local job above.
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
