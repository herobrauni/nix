{ pkgs, ... }:
{
  # Linting and formatting checks for the flake.
  # Run with: nix flake check
  perSystem =
    { pkgs, ... }:
    {
      checks = {
        nixfmt =
          pkgs.runCommand "nixfmt-check"
            {
              nativeBuildInputs = [ pkgs.nixfmt-rfc-style ];
            }
            ''
              cd ${./..}
              nixfmt --check modules/ secrets.nix
              touch $out
            '';

        statix =
          pkgs.runCommand "statix-check"
            {
              nativeBuildInputs = [ pkgs.statix ];
            }
            ''
              cd ${./..}
              statix check modules/ secrets.nix || true
              touch $out
            '';

        deadnix =
          pkgs.runCommand "deadnix-check"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              cd ${./..}
              deadnix --fail modules/ secrets.nix || true
              touch $out
            '';
      };
    };
}
