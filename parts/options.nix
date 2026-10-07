{ lib, ... }:
let
  inherit (builtins) length;

  inherit (lib)
    mkOption
    types
    ;

  inherit (types)
    listOf
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

    root = mkOption {
      type = nullOr types.path;
      default = null;
    };

    builders = mkOption {
      type = attrsOf (
        submodule (
          { name, ... }: {
            options = {
              name = mkOption {
                type = types.str;
                default = name;
              };

              modules = mkOption {
                type = listOf types.deferredModule;
                default = [ ];
              };

              searchPaths = mkOption {
                type = listOf types.path;
                default = [ ];
              };

              buildFunctions = mkOption {
                type = attrsOf (functionTo types.attrs);
                default = { };
              };

              aggregateFunctions = mkOption {
                type = attrsOf (functionTo types.attrs);
                default = { };
              };

              specialArgs = mkOption {
                type = lazyAttrsOf (types.raw);
                default = { };
              };

              meta = {
                buildDescriptions = mkOption {
                  type = addCheck (attrsOf types.str) (value: (length value) <= 32);
                  default = { };
                  description = ''
                    A brief description of each build function's outputs/responsibilities.
                    Preferably, just the name of the location(s) the function places outputs in.
                    (32 character limit)
                  '';
                };

                description = mkOption {
                  type = types.str;
                  default = "";
                };

                authors = mkOption {
                  type = listOf types.str;
                  default = [ ];
                };

                version = mkOption {
                  type = nullOr types.str;
                  default = null;
                };

                template = mkOption {
                  type = nullOr types.path;
                  default = null;
                };
              };
            };
          }
        )
      );

      default = { };

      description = ''
        A set of builder specifications.
      '';
    };

    internal = {
      builders = mkOption {
        type = attrsOf (submodule {
          options = {
            name = mkOption {
              type = types.str;
              default = "";
            };

            description = mkOption {
              type = types.str;
              default = "";
            };

            authors = mkOption {
              type = listOf types.str;
              default = [ ];
            };

            version = mkOption {
              type = nullOr types.str;
              default = "";
            };

            search_paths = mkOption {
              type = listOf types.str;
              default = [ ];
            };

            build_functions = mkOption {
              type = listOf types.str;
              default = [ ];
            };

            aggregate_functions = mkOption {
              type = listOf types.str;
              default = [ ];
            };

            default_path = mkOption {
              type = types.str;
              default = [ ];
            };

            template_path = mkOption {
              type = nullOr types.str;
              default = null;
            };
          };
        });

        default = { };
        description = ''
          Internal schema for the CLI tool.
        '';
      };

      defaultPathMappings = mkOption {
        type = lazyAttrsOf (types.path);
        default = { };
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
      type = attrsOf (
        submodule (
          { name, ... }: {
            options = {
              name = mkOption {
                type = types.str;
                default = name;
              };

              searchPaths = lib.mkOption {
                type = listOf types.path;
                default = [ ];
              };

              modules = mkOption {
                type = listOf types.deferredModule;
                default = [ ];
              };

              buildFunctions = mkOption {
                type = attrsOf (functionTo types.attrs);
                default = { };
              };

              aggregateFunctions = mkOption {
                type = attrsOf (functionTo types.attrs);
                default = { };
              };

              specialArgs = mkOption {
                type = lazyAttrsOf (types.raw);
                default = { };
              };

              meta = {
                description = mkOption {
                  type = types.str;
                  default = "";
                };

                authors = mkOption {
                  type = listOf types.str;
                  default = [ ];
                };

                version = mkOption {
                  type = nullOr types.str;
                  default = null;
                };

                template = mkOption {
                  type = nullOr types.path;
                  default = null;
                  description = ''
                    A path to a template of a new buildable object.
                    Intended for use with the CLI tool.
                  '';
                };
              };
            };
          }
        )
      );

      default = { };

      description = ''
        A set of builder specifications.
      '';
    };
  };
}
