{ lib, ... }:

let
  inherit (lib) mkOption types;
  inherit (types) nullOr;
in
{
  options = {
    entrypoint = mkOption {
      type = nullOr types.path;
      default = null;
      description = ''
        The path to the template folder. defaults to ./template
      '';
    };

    description = mkOption {
      type = types.str;
      default = "";
      description = ''
        The description of this template.
      '';
    };

    message = mkOption {
      type = types.str;
      default = "";
      description = ''
        Welcome message shown when you initialize the template.
      '';
    };
  };
}
