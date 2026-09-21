{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

  outputs = inputs@{ self, flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } ({ config, lib, ... }: {
      flake.lib = import ./lib {
        inherit inputs lib;
        exts = [
          (import ./lib/exts/options.nix)
          (import ./lib/exts/files.nix)
        ];
      };

      flake.flakeModules.den = ./parts;
      flake.flakeModules.default = config.flake.flakeModules.den;
    }
  );
}
