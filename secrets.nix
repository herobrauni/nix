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

  # Host keys — populate after first deploy:
  gigahost1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4zTijNoKXYhh3Qc8gFcq/r9D5pA3QKPH4hZ5gnAwz4";
  crunchbits1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElegCEHEmy9MIsdkOMLMnbL9L+j6xKc2H5X0Q+PLyE3 root@crunchbits1";
  gc5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0EqYSa1Kc/yucEBeqoUFmKTGQxyZPL8ESfyJ83jqMY root@nixos-installer";

  personal = sshKeys.brauni;
in
{
  "secrets/shared/atuin-password.age".publicKeys = personal ++ [
    gigahost1
    crunchbits1
    gc5
  ];
  "secrets/shared/atuin-key.age".publicKeys = personal ++ [
    gigahost1
    crunchbits1
    gc5
  ];
  "modules/hosts/gigahost1/secrets/beszel.age".publicKeys = personal ++ [ gigahost1 ];
  "modules/hosts/gigahost1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ gigahost1 ];
  "modules/hosts/crunchbits1/secrets/beszel.age".publicKeys = personal ++ [ crunchbits1 ];
  "modules/hosts/crunchbits1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ crunchbits1 ];
  "modules/hosts/gc5/secrets/beszel.age".publicKeys = personal ++ [ gc5 ];
  "modules/hosts/gc5/secrets/netbird-setup-key.age".publicKeys = personal ++ [ gc5 ];

  # Example shared secret
  # "secrets/shared/example.age".publicKeys = personal ++ [ gigahost1 ];

  # Example host-specific secret
  # "modules/hosts/gigahost1/secrets/example.age".publicKeys = personal ++ [ gigahost1 ];
}
