{
  lib,
  config,
  nixpkgs,
  ...
}: let
  cfg = config.myModule;
in {
  options = {
    myModule.enable = lib.mkEnableOption "Enable Module";
  };

  config = lib.mkIf cfg.enable {
    imports = [
      (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
      (nixpkgs.outPath + "/nixos/modules/profiles/headless.nix")
      (nixpkgs.outPath + "/nixos/modules/profiles/perlless.nix")
      ../../modules/users/brauni.nix
    ];
    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    networking.enableIPv6 = true;
    networking.interfaces.enp0s6.useDHCP = lib.mkDefault true;
    nix.settings.experimental-features = ["nix-command" "flakes"];
    nixpkgs.config.allowUnfree = true;

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    zramSwap.enable = true;
    boot.tmp.cleanOnBoot = true;
  };
}
