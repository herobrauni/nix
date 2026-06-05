{ den, lib, ... }:
let
  sshKeys = import ../../lib/ssh-keys.nix;
in
{
  den.aspects.brauni = {
    includes = [
      den.provides.primary-user
      { brauni-ssh-keys.nixos.users.users.brauni.openssh.authorizedKeys.keys = sshKeys.brauni; }
    ];

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
          export ATUIN_SYNC_ADDRESS="https://atuin.brauni.dev"

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
        users.users.brauni = {
          shell = pkgs.nushell;
          openssh.authorizedKeys.keys = sshKeys.brauni;
        };

        systemd.services."atuin-auto-login" = lib.mkIf hasAtuinSecrets {
          description = "Ensure brauni is logged into Atuin";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          unitConfig.ConditionPathExists = [
            config.age.secrets."atuin-password".path
            config.age.secrets."atuin-key".path
          ];
          serviceConfig = {
            Type = "oneshot";
            User = "brauni";
            WorkingDirectory = "/home/brauni";
            UMask = "0077";
            ExecStart = atuinAutoLogin;
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
        home.activation.removeStaleConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
          for f in fish/config.fish atuin/config.toml nushell/config.nu nushell/env.nu; do
            rm -f "${config.home.homeDirectory}/.config/$f"
          done
        '';

        home.packages = with pkgs; [
          chezmoi
          curl
          fd
          git
          htop
          tmux
          tree
          vim
          wget
        ];

        programs.fish = {
          enable = true;
          interactiveShellInit = ''
            ${lib.getExe pkgs.atuin} hex init fish | source
          '';
        };

        programs.nushell = {
          enable = true;

          settings = {
            buffer_editor = "nano";
          };

          shellAliases = {
            ap = "ansible-playbook";
            ce = "chezmoi edit";
            cm = "chezmoi";
            f = "flux";
            ff = "systemctl --user start app-org.mozilla.firefox@autostart.service";
            fr = "flux reconcile source git flux-system";
            k = "kubectl";
            kh = "kubectl get hr -A";
            kk = "kubectl get ks -A";
            lg = "lazygit";
            py = "uv run";
            pypy = "uv run --python pypy3";
            t = "talosctl";
            th = "talhelper";
            ts = "tailscale ssh";
            y = "yazi";
          };

          extraConfig = ''
            # Atuin init (hex / pty-proxy)
            source ${
              pkgs.runCommand "atuin-hex-init.nu"
                {
                  nativeBuildInputs = [ pkgs.writableTmpDirAsHomeHook ];
                }
                ''
                  ${lib.getExe pkgs.atuin} init nu >> "$out"
                  ${lib.getExe pkgs.atuin} pty-proxy init nu >> "$out"
                ''
            }

            # Fish-style inline autosuggestions (powered by atuin history)
            $env.config.hinter.closure = {|ctx|
              if ($ctx.line | str length) == 0 {
                return null
              }
              let candidate = (try {
                ^atuin search --cwd $ctx.cwd --limit 1 --search-mode prefix --cmd-only $ctx.line
                | lines
                | first
              } catch {
                null
              })
              if $candidate == null or not ($candidate | str starts-with $ctx.line) {
                null
              } else {
                $candidate | str substring ($ctx.line | str length)..
              }
            }

            # chezmoi source-path (evaluated at call time, not alias-frozen)
            def ccd [] { cd (chezmoi source-path) }

            # Custom commands
            def la [folder?] {
              match $folder {
                null => { ls -la | sort-by type name }
                _ => { ls -la $folder | sort-by type name }
              }
            }

            def gpush [message?: string] {
              git add .
              match $message {
                null => { git commit -m "update" }
                _ => { git commit -m $message }
              }
              git push
            }

            # Launch Atuin AI inline when typing '?' on an empty line
            def "?" [] {
              let output = (^atuin ai inline --hook e>| str trim)
              if ($output | str starts-with "__atuin_ai_execute__:") {
                let cmd = ($output | str replace "__atuin_ai_execute__:" "")
                commandline edit --accept $cmd
              } else if ($output | str starts-with "__atuin_ai_insert__:") {
                let cmd = ($output | str replace "__atuin_ai_insert__:" "")
                commandline edit --replace $cmd
              } else if ($output | str starts-with "__atuin_ai_print__:") {
                let text = ($output | str replace "__atuin_ai_print__:" "")
                print $text
              } else if ($output == "__atuin_ai_cancel__") {
              } else if ($output | is-not-empty) {
                commandline edit --replace $output
              }
            }

            # sudo toggle — Alt+S
            def _sudo_toggle [] {
              let buf = (commandline)
              if ($buf | str trim | is-empty) {
                let last = (history | last | get command | str trim)
                let cmd = if $last == "_sudo_toggle" {
                  history | last 2 | first | get command | str trim
                } else { $last }
                if ($cmd | str starts-with "sudo ") {
                  commandline edit --replace $cmd
                } else {
                  commandline edit --replace $"sudo ($cmd)"
                }
              } else {
                let cursor = (commandline get-cursor)
                if ($buf | str starts-with "sudo ") {
                  let newbuf = ($buf | str replace --regex '^sudo ' "")
                  commandline edit --replace $newbuf
                  commandline set-cursor ($cursor - 5)
                } else {
                  let newbuf = $"sudo ($buf)"
                  commandline edit --replace $newbuf
                  commandline set-cursor ($cursor + 5)
                }
              }
            }

            $env.config.keybindings = ($env.config.keybindings | default [] | append {
              name: sudo_toggle
              modifier: alt
              keycode: char_s
              mode: [emacs, vi_normal, vi_insert]
              event: { send: executehostcommand cmd: "_sudo_toggle" }
            })
          '';
        };

        programs.carapace = {
          enable = true;
          enableNushellIntegration = true;
        };

        programs.starship = {
          enable = true;
          enableNushellIntegration = true;
        };

        programs.zoxide = {
          enable = true;
          enableNushellIntegration = true;
        };

        programs.atuin = {
          enable = true;
          enableFishIntegration = true;
          enableNushellIntegration = false;
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
