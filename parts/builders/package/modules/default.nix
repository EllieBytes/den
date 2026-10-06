{ lib, inputs, ... }:

let
  inherit (lib) mkOption types;
  inherit (types) listOf nullOr;
in
{
  options = {
    nixpkgs = mkOption {
      type = types.raw;
      default =
        inputs.nixpkgs or (throw "No input 'nixpkgs' found. consider adding 'nixpkgs' to your inputs");
    };

    systems = mkOption {
      type = listOf types.str;
      default = [ "x86_64-linux" ];
    };

    entrypoint = mkOption {
      type = nullOr types.path;
      default = null;
      description = ''
        The entry point of the package/derivation.
      '';
    };

    args = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        Arguments passed to pkgs.callPackage
      '';
    };
  };
}
