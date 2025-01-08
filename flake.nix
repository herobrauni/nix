{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    # Helper function to create system configurations
    mkSystem = system: hostName:
      nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/${hostName}/configuration.nix
        ];
        specialArgs = {inherit inputs nixpkgs;};
      };
  in {
    nixosConfigurations = {
      # Example configurations:
      # x86-host = mkSystem "x86_64-linux" "x86-host";
      # arm-server = mkSystem "aarch64-linux" "arm-server";
      kuroit2 = mkSystem "x86_64-linux" "kuroit2";
    };
  };
}
