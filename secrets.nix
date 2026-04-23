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
  # brauni's personal keys (from https://github.com/herobrauni.keys)
  brauni = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmpZL3J2RqRK7ynIgowaZBKzI+EiuCGmwB6l0AxLk1v";
  brauni2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa";

  # Host keys — populate after first deploy:
  nixos = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAig9U9QbDqK+pOklbYOni1MaMTbZALGAvV1L98OzqD0 root@nixos";
  nixos2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBzHy4LmBrl2Cqv2JTKLjhX+JECcaZePx9saKWhA1rGK root@nixos";
  gigahost1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP4zTijNoKXYhh3Qc8gFcq/r9D5pA3QKPH4hZ5gnAwz4";
  crunchbits1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHGxBe6ZK/2vDs3olmlT8at8srlxUJlpZcOsVKD0dSi6";
  gc5 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK0EqYSa1Kc/yucEBeqoUFmKTGQxyZPL8ESfyJ83jqMY root@nixos-installer";

  # All personal keys (for secrets brauni should be able to decrypt locally)
  personal = [
    brauni
    brauni2
  ];
in
{
  "secrets/shared/atuin-password.age".publicKeys = personal ++ [
    nixos
    nixos2
    gigahost1
    crunchbits1
    gc5
  ];
  "modules/hosts/nixos2/secrets/root-password-hash.age".publicKeys = personal ++ [ nixos2 ];
  "modules/hosts/gigahost1/secrets/beszel.age".publicKeys = personal ++ [ gigahost1 ];
  "modules/hosts/gigahost1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ gigahost1 ];
  "modules/hosts/crunchbits1/secrets/beszel.age".publicKeys = personal ++ [ crunchbits1 ];
  "modules/hosts/crunchbits1/secrets/netbird-setup-key.age".publicKeys = personal ++ [ crunchbits1 ];
  "modules/hosts/gc5/secrets/beszel.age".publicKeys = personal ++ [ gc5 ];
  "modules/hosts/gc5/secrets/netbird-setup-key.age".publicKeys = personal ++ [ gc5 ];

  # Example shared secret
  # "secrets/shared/example.age".publicKeys = personal ++ [ nixos ];

  # Example host-specific secret
  # "modules/hosts/nixos2/secrets/example.age".publicKeys = personal ++ [ nixos2 ];
}
