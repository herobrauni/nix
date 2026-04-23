{ ... }:
{
  # Shared maintenance policy for unattended servers.
  den.aspects.maintenance = {
    nixos = {
      nix = {
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 7d";
        };

        optimise = {
          automatic = true;
          dates = [ "weekly" ];
        };
      };

      services.fstrim.enable = true;

      system.autoUpgrade = {
        enable = true;

        # Poll main every night, but honour the repo's committed flake.lock.
        # The repo's scheduled flake update workflow moves inputs forward;
        # hosts only consume what already landed.
        flake = "github:herobrauni/nix?ref=main";
        upgrade = false;

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
