{ den, lib, ... }:
let
  sshKeys = import ../../lib/ssh-keys.nix;
in
{
  den.aspects.brauni = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
      { brauni-ssh-keys.nixos.users.users.brauni.openssh.authorizedKeys.keys = sshKeys.brauni; }
    ];

    # SSH keys for remote access + shared user-level services.
    nixos =
      {
        config,
        lib,
        pkgs,
        options,
        ...
      }:
      let
        hasAtuinSecrets =
          config ? age
          && builtins.hasAttr "atuin-password" config.age.secrets
          && builtins.hasAttr "atuin-key" config.age.secrets;
        atuinBin = lib.getExe pkgs.atuin;
        atuinAutoLogin = pkgs.writeShellScript "atuin-auto-login" ''
          set -euo pipefail

          export HOME=/home/brauni
          export XDG_CONFIG_HOME="$HOME/.config"
          export XDG_DATA_HOME="$HOME/.local/share"
          export XDG_STATE_HOME="$HOME/.local/state"

          ${pkgs.coreutils}/bin/mkdir -p "$XDG_DATA_HOME/atuin" "$XDG_STATE_HOME"
          export ATUIN_SESSION="$(${atuinBin} uuid)"

          password="$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets."atuin-password".path})"
          key="$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets."atuin-key".path})"
          current_key="$({ ${atuinBin} key --base64 2>/dev/null || true; } | ${pkgs.coreutils}/bin/tr -d '\n')"
          key_mismatch=0

          if ${atuinBin} status >/dev/null 2>&1 && [ "$current_key" = "$key" ]; then
            ${atuinBin} sync >/dev/null
            ${atuinBin} status >/dev/null
            exit 0
          fi

          if [ -n "$current_key" ] && [ "$current_key" != "$key" ]; then
            echo "Atuin key mismatch; resetting local Atuin login and purging undecryptable local records"
            key_mismatch=1
            ${atuinBin} logout >/dev/null 2>&1 || true
            ${pkgs.coreutils}/bin/rm -f "$XDG_DATA_HOME/atuin/key"
          fi

          ${atuinBin} login \
            --username brauni \
            --password "$password" \
            --key "$key"

          if [ "$key_mismatch" = 1 ]; then
            ${atuinBin} store purge >/dev/null 2>&1 || true
          fi

          ${atuinBin} sync >/dev/null
          ${atuinBin} status >/dev/null
        '';
      in
      {
        users.users.brauni.openssh.authorizedKeys.keys = sshKeys.brauni;

        systemd.services."atuin-auto-login" = lib.mkIf hasAtuinSecrets {
          description = "Ensure brauni is logged into Atuin";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];
          unitConfig = {
            ConditionPathExists = [
              config.age.secrets."atuin-password".path
              config.age.secrets."atuin-key".path
            ];
            # Don't fail boot/switch if this unit fails — the timer will retry.
            FailureAction = "none";
          };
          serviceConfig = {
            Type = "oneshot";
            User = "brauni";
            WorkingDirectory = "/home/brauni";
            UMask = "0077";
            ExecStart = atuinAutoLogin;
            # Retry a few times with backoff on transient failures.
            Restart = "on-failure";
            RestartSec = "30s";
            RestartMaxDelaySec = "5min";
          };
        };

        systemd.timers."atuin-auto-login" = lib.mkIf hasAtuinSecrets {
          description = "Retry brauni Atuin login if the session is missing";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnBootSec = "5min";
            OnUnitActiveSec = "1h";
            Persistent = true;
            RandomizedDelaySec = "10min";
            Unit = "atuin-auto-login.service";
          };
        };
      };

    homeManager =
      {
        config,
        pkgs,
        lib,
        ...
      }:
      {
        # Prevent "would be clobbered" errors when Fish and Atuin
        # have written to their config files (converting HM symlinks
        # to regular files). Clean them up before activation links fresh ones.
        home.activation.removeStaleConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          for f in fish/config.fish atuin/config.toml; do
            rm -f "${config.home.homeDirectory}/.config/$f"
          done
        '';

        home.packages = with pkgs; [
          git
          vim
          htop
          tmux
          curl
          wget
          fd
          tree
        ];

        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            ${lib.getExe pkgs.atuin} hex init fish | source
          '';
        };

        programs.atuin = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            auto_sync = true;
            sync_address = "https://atuin.brauni.dev";
            sync_frequency = "5m";
            search_mode = "daemon-fuzzy";
            sync.records = true;
            dotfiles.enabled = true;
            daemon = {
              enabled = true;
              autostart = true;
            };
            ai.enabled = true;
          };
        };

        programs.git = {
          enable = true;
          settings = {
            user.name = "brauni";
            init.defaultBranch = "main";
            core.autocrlf = "input";
          };
        };

        # Note: home.persistence is handled by the impermanence aspect,
        # which conditionally adds it only for hosts that include impermanence.
      };
  };
}
