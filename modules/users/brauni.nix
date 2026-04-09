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
          # TODO: set your name and email
          # settings.user.name = "brauni";
          # settings.user.email = "you@example.com";
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
