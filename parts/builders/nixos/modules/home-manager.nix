{ inputs, lib, ... }:

let
  inherit (lib) mkEnableOption mkOption types;
  inherit (types) listOf nullOr;
in
{
  options.home-manager = {
    home-manager = mkOption {
      type = nullOr types.raw;
      default = inputs.home-manager or null;
    };

    enable = mkEnableOption "home-manager";

    importUsers = mkOption {
      type = listOf types.str;
      default = [ ];
      description = ''
        List of user names to attempt to import from `config.flake.homeConfigurations`
      '';
    };

    users = mkOption {
      type = types.attrs;
      default = { };
      description = ''
        users to inject into home-manager.users
      '';
    };

    extraModules = mkOption {
      type = listOf types.deferredModule;
      default = [ ];
      description = ''
        extra modules to add to users' configurations.
      '';
    };

    useGlobalPkgs = mkOption {
      type = types.bool;
      default = true;
    };

    useUserPackages = mkOption {
      type = types.bool;
      default = true;
    };
  };
}
