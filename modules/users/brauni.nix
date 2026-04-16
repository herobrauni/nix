{ den, lib, ... }:
{
  den.aspects.brauni = {
    includes = [
      den.provides.primary-user
      (den.provides.user-shell "fish")
    ];

    # SSH keys for remote access
    nixos = {
      users.users.brauni.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmpZL3J2RqRK7ynIgowaZBKzI+EiuCGmwB6l0AxLk1v"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa"
      ];
    }
    // lib.optionalAttrs (builtins.pathExists ../../secrets/shared/atuin-password.age) {
      age.secrets.atuin-password = {
        file = ../../secrets/shared/atuin-password.age;
        owner = "brauni";
        mode = "0400";
      };
    };

    homeManager =
      {
        pkgs,
        lib,
        config,
        osConfig,
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
      }
      //
        lib.optionalAttrs
          ((osConfig ? age) && (osConfig.age ? secrets) && (osConfig.age.secrets ? atuin-password))
          {
            home.activation.atuinLogin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              if ! ${config.programs.atuin.package}/bin/atuin status >/dev/null 2>&1; then
                $DRY_RUN_CMD ${config.programs.atuin.package}/bin/atuin login \
                  --username brauni \
                  --password "$(cat ${osConfig.age.secrets.atuin-password.path})"
              fi
            '';
          };
  };
}
