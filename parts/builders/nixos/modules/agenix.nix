{
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkOption types;
  inherit (types) nullOr;
in
{
  options.agenix = {
    agenix = mkOption {
      type = nullOr types.raw;
      default = inputs.agenix or null;
    };

    enable = mkEnableOption "agenix";
  };
}
