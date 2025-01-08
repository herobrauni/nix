{
  lib,
  config,
  nixpkgs,
  ...
}: {
  imports = [
    (nixpkgs.outPath + "/nixos/modules/profiles/minimal.nix")
    (nixpkgs.outPath + "/nixos/modules/profiles/headless.nix")
    (nixpkgs.outPath + "/nixos/modules/profiles/perlless.nix")
    ../users/brauni.nix
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
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  swapDevices = [
    {
      device = "/swapfile";
      size = 1110;
    }
  ];
  boot.kernelParams = ["console=ttyS0,115200n8" "console=tty0"];
}
