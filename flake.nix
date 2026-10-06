{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  inputs.devshell.url = "github:numtide/devshell";
  inputs.treefmt-nix.url = "github:numtide/treefmt-nix";

  outputs =
    inputs@{
      self,
      flake-parts,
      nixpkgs,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      {
        config,
        lib,
        withSystem,
        ...
      }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];

        imports = [
          inputs.devshell.flakeModule
          inputs.treefmt-nix.flakeModule
        ];

        flake.lib = import ./lib {
          inherit inputs lib;
          exts = [
            (import ./lib/exts/options.nix)
            (import ./lib/exts/files.nix)
            (import ./lib/exts/helpers.nix)
            (import ./lib/exts/attrs.nix)
          ];
        };

        flake.flakeModule = config.flake.flakeModules.den;
        flake.flakeModules.den = flake-parts.lib.importApply ./parts/default.nix {
          inherit withSystem;
          inherit (config.flake) lib;
        };
        flake.flakeModules.default = config.flake.flakeModules.den;

        perSystem = { pkgs, ... }: {
          devshells.default = {
            packages = with pkgs; [
              nix
              nixd
              nixfmt
              package-version-server
              just
              git
              direnv
              cargo
              rust-analyzer
              gcc
              rustc
            ];
          };

          treefmt = {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.rustfmt.enable = true;
          };
        };
      }
    );
}
