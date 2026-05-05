{ inputs, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  flake-file.nixConfig = {
    # Let hosts with max-jobs = 0 substitute NixOS' trivial
    # preferLocalBuild derivations before this setting exists in /etc/nix/nix.conf.
    always-allow-substitutes = true;

    extra-substituters = [ "https://niks3.brauni.dev" ];
    extra-trusted-public-keys = [ "SIGNING_KEY:L2S1rOofwctOTq+ygU/myKHJGhuL2qu/hzAOD1q2SG4=" ];
  };

  flake-file.inputs = {
    den.url = "github:vic/den";
    flake-file.url = "github:vic/flake-file";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-lib.follows = "nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    disko.url = "github:nix-community/disko";
  };
}
