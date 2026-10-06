{ lib, inputs, ... }:

let
  inherit (lib) mkOption types;
  inherit (types) nullOr listOf lazyAttrsOf;
in
{
  options = {
    system = mkOption {
      type = types.str;
      default = "x86_64-linux";
    };

    nixpkgs = mkOption {
      type = nullOr types.raw;
      default = inputs.nixpkgs or null;
    };

    home-manager = mkOption {
      type = nullOr types.raw;
      default = inputs.home-manager or null;
    };

    pkgs = mkOption {
      type = nullOr types.raw;
      default = null;
    };

    extraModules = mkOption {
      type = listOf types.deferredModule;
      default = [ ];
    };

    extraSpecialArgs = mkOption {
      type = lazyAttrsOf types.raw;
      default = { };
    };
  };
}
