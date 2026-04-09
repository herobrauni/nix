{ den, ... }:
{
  den.aspects.brauni = {
    includes = [
      den.provides.define-user
      den.provides.primary-user
      (den.provides.user-shell "bash")
    ];

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
          userName = "brauni";
          # TODO: set your email
          # userEmail = "you@example.com";
        };

        # Persist home-manager state across reboots (for impermanence)
        # NOTE: impermanence appends the home directory path automatically
        home.persistence."/persist" = {
          directories = [
            ".ssh"
            ".local/share"
            ".config"
            ".cache"
            ".tmux"
          ];
          files = [
            ".bash_history"
          ];
        };
      };
  };
}
