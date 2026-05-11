{ ... }:
{
  # Shared dev-tools aspect for development machines.
  # Installs pi-coding-agent (with nodejs for extension management)
  # and ensures ~/.pi persists on impermanence hosts.
  den.aspects.dev-tools = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = [
          pkgs.pi-coding-agent
          # pi install/remove needs npm for extension management
          pkgs.nodejs
        ];

        # pi install uses npm install -g, which defaults to the nix store.
        # Point npm to a writable prefix so extensions survive reboots.
        environment.variables.NPM_CONFIG_PREFIX = "$HOME/.local";
      };
  };
}
