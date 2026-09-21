{ inputs, lib, ... }:

let
  inherit (lib) mkOption types;
in {
  options = {
    nixpkgs = {
      nixpkgs = mkOption {
        type = types.raw;
        default = inputs.nixpkgs;
      };
    };
  };
}
