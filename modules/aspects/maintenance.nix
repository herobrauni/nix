{ ... }:
{
  # Shared maintenance policy for unattended servers.
  den.aspects.maintenance = {
    nixos = {
      nix = {
        gc = {
          automatic = true;
          # Run daily – matches the nightly autoUpgrade cadence so the store
          # never accumulates more than a handful of generations.
          dates = "daily";
          # Keep 3 generations (enough for rollback), remove anything older.
          options = "--delete-older-than 3d";
        };

        optimise = {
          automatic = true;
          # Daily dedup keeps the floor lower between GC runs.
          dates = [ "daily" ];
        };
      };

      services.fstrim.enable = true;

      system.autoUpgrade = {
        enable = true;

        # Poll main every night, but honour the repo's committed flake.lock.
        # The repo's scheduled flake update workflow moves inputs forward;
        # hosts only consume what already landed.
        #
        # Use git+https:// instead of github: — the github: scheme resolves
        # ref=main via the GitHub REST API, which rate-limits unauthenticated
        # requests (60/hr per IP) and intermittently returns 504s during the
        # 04:00 UTC window. git+https:// uses 'git fetch' with no API dependency.
        flake = "git+https://github.com/herobrauni/nix.git?ref=main";
        upgrade = false;

        # -L: print build logs to journal for visibility
        # -v: verbose nixos-rebuild output
        # --refresh: force fresh git fetch (no GitHub API involved with git+https)
        flags = [
          "--refresh"
          "--flake git+https://github.com/herobrauni/nix.git?ref=main"
          "-L"
          "-v"
        ];

        # All servers use UTC (see server-core), so this runs at 04:00 UTC.
        dates = "04:00";
        randomizedDelaySec = "30min";
        fixedRandomDelay = true;

        allowReboot = true;
        rebootWindow = {
          lower = "03:00";
          upper = "05:00";
        };
      };
    };
  };
}
