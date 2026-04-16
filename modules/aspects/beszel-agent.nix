{ den, lib, ... }:
{
  den.aspects.beszel-agent.nixos =
    { config, pkgs, ... }:
    {
      assertions = [
        {
          assertion = config.age.secrets ? beszel;
          message = "den.aspects.beszel-agent requires age.secrets.beszel. Create modules/hosts/<hostname>/secrets/beszel.age and wire it via a host secret module.";
        }
      ];

      services.beszel.agent = {
        enable = true;
        openFirewall = true;
        # nixpkgs is still on 0.18.6; keep a local override until 0.18.7 lands upstream.
        package = pkgs.callPackage ../../pkgs/beszel-0.18.7.nix { };
        environment.HUB_URL = "https://beszel.riki.boo";
        environmentFile = config.age.secrets.beszel.path;
      };
    };
}
