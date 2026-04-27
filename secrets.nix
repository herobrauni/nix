# Agenix secrets declarations.
# This file is read by the `agenix` CLI to know which keys can decrypt which secrets.
#
# To create/edit a shared secret:
#   cd /path/to/repo && agenix -e secrets/shared/mysecret.age
#
# To create/edit a host-specific secret:
#   cd /path/to/repo && agenix -e modules/hosts/<hostname>/secrets/mysecret.age
#   # then declare it in modules/hosts/<hostname>/secrets/<name>.nix
#
# After adding a new host key, rekey all secrets:
#   agenix --rekey
#
# Host keys will be populated after first deploy.
# Run `ssh-keyscan <host>` and add the ed25519 key below.

let
  sshKeys = import ./lib/ssh-keys.nix;

  # WARNING: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa
  # (brauni-old / bitwarden incident key) is COMPROMISED.
  # Never use it as a recipient or identity again.

  # Host keys — populate after first deploy:
  gigahost1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4zTijNoKXYhh3Qc8gFcq/r9D5pA3QKPH4hZ5gnAwz4";
  crunchbits1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFq9hgSw5ZPyYzN4EjYLbq35ckxKDcXWyQ0CT4CcFBLq root@crunchbits1";
  gc5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0EqYSa1Kc/yucEBeqoUFmKTGQxyZPL8ESfyJ83jqMY root@nixos-installer";
  alpha1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeEyFsKYw3YBGVtBsDoSjzy/vr5wkkuJAtzYxN6gnQl root@alpha1";

  personal = sshKeys.brauni;
in
{
  "secrets/shared/atuin-password.age".publicKeys = personal ++ [
    gigahost1
    crunchbits1
    gc5
    alpha1
  ];
  "secrets/shared/atuin-key.age".publicKeys = personal ++ [
    gigahost1
    crunchbits1
    gc5
    alpha1
  ];
  "modules/hosts/gigahost1/secrets/beszel.age".publicKeys = personal ++ [ gigahost1 ];
  "modules/hosts/gigahost1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ gigahost1 ];
  "modules/hosts/crunchbits1/secrets/beszel.age".publicKeys = personal ++ [ crunchbits1 ];
  "modules/hosts/crunchbits1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ crunchbits1 ];
  "modules/hosts/gc5/secrets/beszel.age".publicKeys = personal ++ [ gc5 ];
  "modules/hosts/gc5/secrets/netbird-setup-key.age".publicKeys = personal ++ [ gc5 ];
  "modules/hosts/alpha1/secrets/beszel.age".publicKeys = personal ++ [ alpha1 ];
  "modules/hosts/alpha1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ alpha1 ];

  # Example shared secret
  # "secrets/shared/example.age".publicKeys = personal ++ [ gigahost1 ];

  # Example host-specific secret
  # "modules/hosts/gigahost1/secrets/example.age".publicKeys = personal ++ [ gigahost1 ];
}
