# Agenix secrets declarations.
# This file is read by the `agenix` CLI to know which keys can decrypt which secrets.
#
# To create/edit a secret:
#   cd /path/to/repo && agenix -e secrets/mysecret.age
#
# After adding a new host key, rekey all secrets:
#   agenix --rekey
#
# Host keys will be populated after first deploy.
# Run `ssh-keyscan nixtest1` and add the ed25519 key below.

let
  # brauni's personal keys (from https://github.com/herobrauni.keys)
  brauni = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJmpZL3J2RqRK7ynIgowaZBKzI+EiuCGmwB6l0AxLk1v";
  brauni2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFfL/A140RdlJ1LQQR/lwtPwf0MAn5haqDdXGKWsW8sa";

  # Host keys — populate after first deploy:
  # nixtest1 = "ssh-ed25519 AAAA... nixtest1";
  nixtest2 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfPnNWDINOx2zVBMIzrLMYT+cWzD0TW+kgUjz0q69ls";

  # All personal keys (for secrets brauni should be able to decrypt locally)
  personal = [ brauni brauni2 ];
in
{
  "secrets/atuin-password.age".publicKeys = personal ++ [ nixtest2 ];

  # Example: uncomment and edit to create your first secret
  # "secrets/nixtest1-example.age".publicKeys = personal ++ [ nixtest1 ];
}
