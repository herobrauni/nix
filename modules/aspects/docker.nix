{
  den,
  ...
}:
{
  # Shared Docker aspect — enables Docker on all hosts that include it.
  den.aspects.docker = {
    # OS-level Docker daemon
    nixos = {
      virtualisation.docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };

      # Allow wheel group to use docker without sudo
      users.extraGroups.docker.members = [ "brauni" ];

      # Persist Docker data on impermanence hosts
      environment.persistence."/persist".directories = [
        "/var/lib/docker"
      ];
    };

    # Docker CLI tools and rootless Docker via podman
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.docker-client ];
      };
  };
}
