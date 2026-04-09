{ den, ... }:
{
  den.aspects.brauni = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "bash")
    ];

    # SSH keys for remote access
    nixos = {
      users.users.brauni.openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmpZL3J2RqRK7ynIgowaZBKzI+EiuCGmwB6l0AxLk1v"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa"
      ];
    };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          git
          vim
          htop
          tmux
          curl
          wget
          jq
          ripgrep
          fd
          tree
        ];

        programs.git = {
          enable = true;
        };

        # TODO: add home.persistence back once we figure out
        # conditional HM module imports in den for non-impermanence hosts
      };
  };
}
