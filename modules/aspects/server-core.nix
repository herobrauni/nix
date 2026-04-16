{ lib, ... }:
{
  # Shared baseline for server-style NixOS hosts.
  den.aspects.server-core = {
    nixos = {
      # ── SSH ───────────────────────────────────────────────────────
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = lib.mkDefault "prohibit-password";
          X11Forwarding = false;
          MaxAuthTries = 3;
          ClientAliveInterval = 300;
          ClientAliveCountMax = 2;
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

      # ── Timezone ─────────────────────────────────────────────────
      time.timeZone = "UTC";

      # ── Locale ───────────────────────────────────────────────────
      i18n.defaultLocale = "en_US.UTF-8";
    };
  };
}
