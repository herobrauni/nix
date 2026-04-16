{ ... }:
{
  # Shared shell support and admin tooling for headless servers.
  den.aspects.ops-tools = {
    nixos =
      { pkgs, ... }:
      {
        # fish is enabled system-wide so it can be used as a login shell.
        programs.fish.enable = true;

        environment.systemPackages = with pkgs; [
          openssh
          curl
          wget
          git
          htop
          btop
          jq
          ripgrep
          fd
          tree
          tmux
          ncdu
          zellij
        ];
      };
  };
}
