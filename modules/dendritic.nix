{ inputs, ... }:
{
  imports = [
    (inputs.flake-file.flakeModules.dendritic or { })
    (inputs.den.flakeModules.dendritic or { })
  ];

  flake-file.nixConfig = {
    # Let hosts apply the cache/fallback policy before the new /etc/nix/nix.conf
    # is active.
    always-allow-substitutes = true;
    cores = 1;

    extra-substituters = [ "https://niks3.brauni.dev" ];
    extra-trusted-public-keys = [ "SIGNING_KEY:L2S1rOofwctOTq+ygU/myKHJGhuL2qu/hzAOD1q2SG4=" ];

    max-jobs = 1;
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
