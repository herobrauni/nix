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
        ...
      }:
      let
        hasAtuinSecrets =
          builtins.hasAttr "atuin-password" config.age.secrets
          && builtins.hasAttr "atuin-key" config.age.secrets;
        atuinBin = lib.getExe pkgs.atuin;
        atuinAutoLogin = pkgs.writeShellScript "atuin-auto-login" ''
          set -euo pipefail

          export HOME=/home/brauni
          export XDG_CONFIG_HOME="$HOME/.config"
          export XDG_DATA_HOME="$HOME/.local/share"
          export XDG_STATE_HOME="$HOME/.local/state"

          ${pkgs.coreutils}/bin/mkdir -p "$XDG_DATA_HOME/atuin" "$XDG_STATE_HOME"

          if ${atuinBin} status >/dev/null 2>&1; then
            exit 0
          fi

          password="$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets."atuin-password".path})"
          key="$(${pkgs.coreutils}/bin/tr -d '\n' < ${config.age.secrets."atuin-key".path})"

          ${atuinBin} login \
            --username brauni \
            --password "$password" \
            --key "$key"

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
          serviceConfig = {
            Type = "oneshot";
            User = "brauni";
            WorkingDirectory = "/home/brauni";
            UMask = "0077";
            ExecStart = atuinAutoLogin;
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
        pkgs,
        lib,
        ...
      }:
      {
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

        programs.fish.enable = true;

        programs.atuin = {
          enable = true;
          enableFishIntegration = true;
          settings = {
            auto_sync = true;
            sync_address = "https://atuin.brauni.dev";
            sync_frequency = "5m";
            search_mode = "prefix";
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
