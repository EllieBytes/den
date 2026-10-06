{
  description = "Flake using Den.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    den.url = "github:EllieBytes/den";
    den.inputs.flake-parts.follows = "flake-parts";
    den.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ den, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ den.flakeModule ];

      den.root = ./.;
    };
}
