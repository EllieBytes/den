{ lib, ... }:

let
  # Builder primitive.
  mkBuilder = {
    name,
    modules ? [],
    # Note to builders.
    # Aggregate outputs go to den.buildOutputs.<builder>
    buildFunction,
    aggregateFunction ? (outputs: []),
    meta ? {},
    specialArgs ? {},
  }: rec {
    inherit name modules buildFunction aggregateFunction meta;

    extend = {
      name ? name,
      extraModules ? [],
      buildFunction ? buildFunction,
      aggregateFunction ? aggregateFunction,
      extraMeta ? {},
      extraSpecialArgs ? {},
    }: mkBuilder {
      inherit name;
      modules = modules ++ extraModules;
      inherit buildFunction aggregateFunction;
      meta = lib.recursiveUpdate meta extraMeta;
      specialArgs = specialArgs // extraSpecialArgs;
    };
  };
in rec {
  inherit mkBuilder;

  buildOutputsToAttrs = outs:
    builtins.foldl' lib.recursiveUpdate {}
      (map ({ path, output }: lib.setAttrByPath path output) outs);

  callBuilder = { config, inputs }: builder: dir:
    let
      found = lib.discoverGenerics {
        baseMetas = builder.modules;
        inherit lib;
        inherit (builder) specialArgs;
      } dir;

      callBuild = { meta, name, path }: f: f {
        flake = config.flake;
        inherit meta inputs name path lib;
      };

      outputs = map ({ name, meta, path, ... }: callBuild { inherit name meta path; } builder.buildFunction) found;
      aggregateOutputs = builder.aggregateFunction outputs;
      dueOutputs = [
        {
          path = [ "flake" "den" "buildOutputs" "${builder.name}" ];
          output = buildOutputsToAttrs outputs;
        }
      ];
      merged = outputs ++ aggregateOutputs ++ dueOutputs;

      final = buildOutputsToAttrs merged;
    in final;

  mergeBuildAttrs = outs:
    foldl' lib.recursiveUpdate {} outs;
}
