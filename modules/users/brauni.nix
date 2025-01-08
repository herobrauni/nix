{
  config,
  lib,
  pkgs,
  ...
}: let
  ifTheyExist = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in {
  users.users.brauni.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBPFkI1tmXLQ5awKEqqoEUMbCalSqARtODdy8nQ18pKk"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIETmaz2oKUkpoSSeGKQefhFb+PUCEwY9Onh9+q1+hXXt"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICvklcYlHcJVJzEAmkevC9eZ/rjCN7d1jhDHMBbVSmkqAAAABHNzaDo="
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIJUzimGYl+VtbaQVuGkVRwxRBMQEJDsmD5g+YeHx2s9bAAAABHNzaDo="
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAINz7Y1oRX+SURSXOoNv5se/hrpi6VvLHK0T3zqz+q5kqAAAABHNzaDo="
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmpZL3J2RqRK7ynIgowaZBKzI+EiuCGmwB6l0AxLk1v"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa"
  ];

  users.mutableUsers = false;
  users.users.brauni = {
    isNormalUser = true;
    extraGroups = ifTheyExist [
      "audio"
      "docker"
      "git"
      "i2c"
      "libvirtd"
      "lxd"
      "network"
      "podman"
      "video"
      "wheel"
    ];
    initialHashedPassword = "$y$j9T$d7EVWIrLInhGgEObbWa0A1$jomM5R056rhtJOOBH5vxC6GRnPMdqCb23ZKNWvqv1L9";
  };
}
