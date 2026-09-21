{ lib, ... }:

let
  inherit (lib) mkOption types;
in {
  imports = [
    ./meta-common.nix
  ];

  options = {
    # TODO: I need to figure out a clean implementation for this, for now a no-op
    extends = mkOption {
      type = types.raw;
      default = null;
      description = ''
        An optional builder to extend.
      '';
    };

    type = mkOption {
      type = types.enum [
        "none"   # Takes no meta.
        "single" # Takes one top-level meta.
        "multi"  # Takes many metas.
      ];

      default = "multi";
      example = "single";
    };

    buildPlans = mkOption {
      type = types.listOf (types.submodule {
        options.path = mkOption {
          type = types.listOf types.str;
        };

        options.builder = mkOption {
          type = types.path;
        };
      });

      default = builtins.warn "No build plans specified, this builder will build nothing..." [];
    };

    metaModules = mkOption {
      type = types.listOf types.deferredModule;
      default = [ ./meta-common.nix ];
      description = ''
        A list of modules to evaluate with the meta.nix
      '';
    }
  };
}
