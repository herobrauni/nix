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
        flake = "github:herobrauni/nix";
        dates = "04:00";
        randomizedDelaySec = "30min";
        allowReboot = true;
        rebootWindow = {
          lower = "03:00";
          upper = "05:00";
        };
      };
    };
  };
}
