{ lib, ... }:

let
  inherit (builtins) traceVerbose;

  inherit (lib)
    mkOption
    types
    ;

  inherit (types)
    listOf
    either
    attrsOf
    submodule
    addCheck
    lazyAttrsOf
    functionTo
    nullOr
    ;
in
{
  options.flake.den = {
    version = mkOption {
      type = types.str;
      readOnly = true;
      default = "0.1.0-alpha";
    };

    builders = mkOption {
      type = attrsOf (submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };

          modules = mkOption {
            type = listOf types.deferredModule;
            default = [];
          };

          searchPaths = mkOption {
            type = listOf types.path;
            default = [];
          };

          buildFunctions = mkOption {
            type = attrsOf (functionTo types.attrs);
            default = {};
          };

          aggregateFunctions = mkOption {
            type = attrsOf (functionTo types.attrs);
            default = {};
          };

          specialArgs = mkOption {
            type = lazyAttrsOf (types.raw);
            default = {};
          };

          meta = {
            description = mkOption {
              type = types.str;
              default = "";
            };

            authors = mkOption {
              type = listOf types.str;
              default = [];
            };

            version = mkOption {
              type = nullOr types.str;
              default = null;
            };
          };
        };
      }));

      default = {};

      description = ''
        A set of builder specifications.
      '';
    };

    internal = {
      forbiddenAttrPaths = mkOption {
        type = addCheck
          (listOf (either types.str (listOf types.str)))
          (value: traceVerbose "den: running with forbidden attrset paths ${toString value}" true);
        default = [ "den" "_module" ];
        description = ''
          Safety feature. prevents builders from generating outputs in bad places.
        '';
      };

      defaultPathMappings = mkOption {
        type = lazyAttrsOf (types.path);
        default = {};
        description = ''
          Mapping for the CLI tool to find a path to place an object.

          WARNING:
            Do not set this manually. this is auto-set by the discovery engine.
        '';
      };
    };
  };

  options.den = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Whether to enable Den.
      '';
    };

    root = mkOption {
      type = nullOr types.path;
      default = null;
      description = ''
        A search root directory.
        setting this allows default search paths to be populated.
        Setting it is optional
      '';
    };

    builders = mkOption {
      type = attrsOf (submodule ({ name, ... }: {
        options = {
          name = mkOption {
            type = types.str;
            default = name;
          };

          searchPaths = lib.mkOption {
            type = listOf types.path;
            default = [];
          };

          modules = mkOption {
            type = listOf types.deferredModule;
            default = [];
          };

          buildFunctions = mkOption {
            type = attrsOf (functionTo types.attrs);
            default = {};
          };

          aggregateFunctions = mkOption {
            type = attrsOf (functionTo types.attrs);
            default = {};
          };

          specialArgs = mkOption {
            type = lazyAttrsOf (types.raw);
            default = {};
          };

          meta = {
            description = mkOption {
              type = types.str;
              default = "";
            };

            authors = mkOption {
              type = listOf types.str;
              default = [];
            };

            version = mkOption {
              type = nullOr types.str;
              default = null;
            };
          };
        };
      }));

      default = {};

      description = ''
        A set of builder specifications.
      '';
    };
  };
}
