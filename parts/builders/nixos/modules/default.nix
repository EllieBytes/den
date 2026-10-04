{
  inputs,
  lib,
  ...
}: let
  inherit (lib) mkOption types;
in {
  options = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''

      '';
    };

    nixpkgs = {
      nixpkgs = mkOption {
        type = types.raw;
        default = inputs.nixpkgs;
      };
    };
  };
}
