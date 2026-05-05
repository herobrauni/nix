{ lib, den, ... }:
{
  # Global defaults — can be overridden per-host.

  # homeManager class is enabled for all users
  den.schema.user.classes = lib.mkDefault [ "homeManager" ];

  # Applied to all hosts, users, and homes.
  # - define-user: creates users.users.<name> on OS + home.username/home.homeDirectory in HM
  # - hostname: sets networking.hostName from host.hostName (auto-derived from host name)
  den.default = {
    nixos =
      { config, ... }:
      {
        home-manager.useUserPackages = true;

        # One-time migration for hosts that previously used HM's default
        # per-user nix-env profile. When useUserPackages becomes true, HM tries
        # to uninstall the old home-manager-path package via nix-env, which
        # creates a local user-environment derivation and fails with max-jobs = 0.
        # If that legacy profile contains only HM's generated package, remove the
        # current profile symlink directly before HM activation runs.
        system.activationScripts.removeLegacyHomeManagerUserProfile.text = ''
          shopt -s nullglob

          for profile in /nix/var/nix/profiles/per-user/*/profile; do
            packages="$(${config.nix.package}/bin/nix-env --profile "$profile" -q 2>/dev/null || true)"

            if [ -L "$profile" ] && [ "$packages" = "home-manager-path" ]; then
              echo "removing legacy Home Manager nix-env profile $profile"
              rm -f "$profile"
            fi
          done
        '';
      };

    homeManager.home.stateVersion = "25.11";
    includes = [
      den._.define-user
      den._.hostname
    ];
  };

  # host <-> user mutual provider
  den.ctx.user.includes = [ den._.mutual-provider ];
}
