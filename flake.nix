{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
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
          {networking.hostName = hostName;}
          ./hosts/${hostName}/configuration.nix
        ];
        specialArgs = {inherit inputs nixpkgs;};
      };
  in {
    nixosConfigurations = {
      # Example configurations:
      # x86-host = mkSystem "x86_64-linux" "x86-host";
      # arm-server = mkSystem "aarch64-linux" "arm-server";
      kuroit1 = mkSystem "x86_64-linux" "kuroit1";
      kuroit2 = mkSystem "x86_64-linux" "kuroit2";
    };
  };
}
