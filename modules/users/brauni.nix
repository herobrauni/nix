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
