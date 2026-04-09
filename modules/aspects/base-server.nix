{ lib, ... }:
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
            PermitRootLogin = lib.mkDefault "prohibit-password";
          };
        };

        # ── Sudo (wheel needs no password for nixos-rebuild) ──────────
        security.sudo.wheelNeedsPassword = false;

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
            # Hosts never build — only substitute from cache
            max-jobs = 0;
            trusted-users = [ "root" "@wheel" ];
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

        # ── Auto-upgrade nightly, pull from cache, reboot if needed ───
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

        # ── Timezone ─────────────────────────────────────────────────
        time.timeZone = "UTC";

        # ── Locale ───────────────────────────────────────────────────
        i18n.defaultLocale = "en_US.UTF-8";
      };
  };
}
