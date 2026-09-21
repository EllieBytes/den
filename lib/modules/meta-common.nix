{ lib, name, ... }:

let
  inherit (lib) types mkOption mkEnableOption';
in
{
  options = {
    enable = mkEnableOption' "this object" true;

    name = mkOption {
      type = types.str;
      default = name;
      description = ''
        The name of this object.
      '';
    };
  };
}
