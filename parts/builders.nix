# Discovery of builders only
# Does not render build plans.
{ config, lib, ... }:

let
  inherit (lib) mkOption types;
  inherit (types) listOf attrsOf submodule functionTo;
in {
  options.den.searchPaths = mkOption {
    type = attrsOf (listOf types.path);
  };

  options.den.builders = mkOption {
    type = attrsOf (submodule {
      options = {
        builder = mkOption {
          type = attrsOf (submodule {
            options = {
              enable = mkEnableOption' "this builder" true;

              name = mkOption {
                type = types.str;
              };

              modules = mkOption {
                type = listOf types.deferredModule;
                default = [];
              };

              buildFunction = mkOption {
                type = functionTo (listOf types.raw);
              };

              aggregateFunction = mkOption {
                type = functionTo (listOf types.raw);
                default = (_: [])
              };

              meta = mkOption {
                type = submodule {
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
                      default = [];
                    };

                    den-version = mkOption {
                      type = types.str;
                      default = "alpha-26.09";
                    };
                  };
                };
              };
            };
          });
        };
      });
  };

  config =
  let
    inherit (config.den) builders;
    inherit (lib.builder) mkBuilder;
  in {
    den.searchPaths.builder = [
      ../builders
    ];

    den.builders.builder.builder = mkBuilder {
      name = "builder";
      modules = [];
      buildFunction = (import ./builders/.builder/build.nix);
      meta = {
        name = "builder";
        description = ''
          Builder that builds a builder.
        '';

        authors = [ "Ellie Johnston <jellie7118@proton.me>" ];
        den-version = "alpha-26.09";
      };
    };
  };
}
