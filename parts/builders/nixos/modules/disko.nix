{ lib, inputs, ... }:

let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types) listOf nullOr;
in
{
  options.disko = {
    disko = mkOption {
      type = nullOr types.raw;
      default = inputs.disko or null;
    };

    enable = mkEnableOption "disko";

    extraModules = mkOption {
      type = listOf types.deferredModule;
      default = [ ];
    };
  };
}
