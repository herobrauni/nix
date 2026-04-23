{ den, lib, ... }:
{
  den.aspects.beszel-agent.nixos =
    { config, ... }:
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
        environment.HUB_URL = "https://beszel.riki.boo";
        environmentFile = config.age.secrets.beszel.path;
      };
    };
}
