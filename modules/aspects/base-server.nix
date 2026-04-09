{ ... }:
{
  # Shared base-server aspect.
  # All servers include this for common configuration.
  den.aspects.base-server = {
    nixos =
      { pkgs, ... }:
      {
        # ── SSH ───────────────────────────────────────────────────────
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "no";
          };
        };

        # ── Firewall ──────────────────────────────────────────────────
        networking.firewall.enable = true;
        networking.firewall.allowedTCPPorts = [ 22 ];

        # ── Zram swap (compressed RAM, good for low-spec VPS) ─────────
        zramSwap = {
          enable = true;
          algorithm = "zstd";
          memoryPercent = 50;
          priority = 999;
        };

        # ── Common system packages ────────────────────────────────────
        environment.systemPackages = with pkgs; [
          openssh
          jq
          ripgrep
        ];

        # ── Nix settings ─────────────────────────────────────────────
        nix = {
          settings = {
            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
            substituters = [ "https://cache.nixos.org" "https://brauni.cachix.org" ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "brauni.cachix.org-1:AK1gTT3vQZQh2OqWS4rh+DjV9lOlqa834O5pssx2rUw="
            ];
          };
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
        };

        # ── Timezone ─────────────────────────────────────────────────
        time.timeZone = "UTC";

        # ── Locale ───────────────────────────────────────────────────
        i18n.defaultLocale = "en_US.UTF-8";

        # ── Automatic upgrades (optional, disabled by default) ────────
        # system.autoUpgrade = {
        #   enable = true;
        #   flake = "github:YOUR-ORG/nix";
        #   dates = "04:00";
        # };
      };
  };
}
