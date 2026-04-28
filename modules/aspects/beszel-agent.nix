{ den, lib, ... }:
{
  den.aspects.beszel-agent.nixos =
    { config, ... }:
    {
      assertions = [
        {
          assertion = config.age.secrets ? beszel;
          message = "den.aspects.beszel-agent requires age.secrets.beszel. Create/edit secrets/shared/beszel.age and declare it in modules/aspects/agenix.nix.";
        }
      ];

      services.beszel.agent = {
        enable = true;
        openFirewall = true;
        environment.HUB_URL = "https://beszel.riki.boo";
        environmentFile = config.age.secrets.beszel.path;
      };
    };
}
