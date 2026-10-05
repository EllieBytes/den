{
  config,
  lib,
  inputs,
  ...
}:

let
  inherit (lib) mkOption mkEnableOption types;
  inherit (types)
    listOf
    nullOr
    attrsOf
    submodule
    ;
in
{
  options.deployment = {
    enable = mkEnableOption "deployment";

    deploy-rs = mkOption {
      type = nullOr types.raw;
      default = inputs.deploy-rs or null;
    };

    hostname = mkOption {
      type = types.str;
      default = config.hostname;
    };

    profilesOrder = mkOption {
      type = listOf types.str;
      default = [ ];
    };

    sshUser = mkOption {
      type = nullOr types.str;
      default = null;
    };

    user = mkOption {
      type = nullOr types.str;
      default = "root";
    };

    sudo = mkOption {
      type = types.str;
      default = "sudo -u";
    };

    interactiveSudo = mkOption {
      type = types.bool;
      default = false;
    };

    sshOpts = mkOption {
      type = listOf types.str;
      default = [ ];
    };

    groups = mkOption {
      type = listOf types.str;
      default = [ ];
    };

    fastConnection = mkOption {
      type = types.bool;
      default = false;
    };

    autoRollback = mkOption {
      type = types.bool;
      default = true;
    };

    magicRollback = mkOption {
      type = types.bool;
      default = true;
    };

    tempPath = mkOption {
      type = types.str;
      default = "/tmp";
    };

    remoteBuild = mkOption {
      type = types.bool;
      default = false;
    };

    activationTimeout = mkOption {
      type = types.int;
      default = 240;
    };

    confirmTimeout = mkOption {
      type = types.int;
      default = 30;
    };

    extraProfiles = mkOption {
      type = attrsOf (submodule {
        options = {
          path = mkOption {
            type = types.raw;
          };

          profilePath = mkOption {
            type = nullOr types.str;
            default = null;
          };
        };

        config._module.freeformType = types.attrs;
      });

      default = { };
      description = ''
        Extra profiles to deploy. A nixos deployment profile is made for you.
      '';
    };
  };
}
