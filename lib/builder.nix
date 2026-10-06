{ lib, ... }:
let
  inherit (builtins)
    attrValues
    foldl'
    elem
    ;

  inherit (lib)
    ifilter0
    discoverGenerics
    lazyMerge
    concatMap
    mapAttrsToList
    ;

  # Builder primitive.
  mkBuilder =
    {
      name,
      modules ? [ ],
      # Note to builders.
      # Aggregate outputs go to den.buildOutputs.<builder>
      buildFunctions ? [ ],
      aggregateFunctions ? [ (outputs: [ ]) ],
      meta ? { },
      specialArgs ? { },
    }:
    rec {
      inherit
        name
        modules
        buildFunctions
        aggregateFunctions
        meta
        specialArgs
        ;

      extend =
        {
          name ? name,
          extraModules ? [ ],
          extraBuildFunctions ? [ ],
          extraAggregateFunctions ? [ ],
          extraMeta ? { },
          extraSpecialArgs ? { },
          buildDiscards ? [ ], # * List of existing build function indices to discard.
          aggregateDiscards ? [ ], # List of aggregate function indices to discard.
          discardAll ? false,
          discardBuilds ? false,
          discardAggregates ? false,
        }:
        let
          oldBuilds =
            if discardAll || discardBuilds then
              [ ]
            else
              ifilter0 (i: _: !(elem i buildDiscards)) buildFunctions;

          oldAggregates =
            if discardAll || discardAggregates then
              [ ]
            else
              ifilter0 (i: _: !(elem i aggregateDiscards)) aggregateFunctions;
        in
        mkBuilder {
          inherit name;
          modules = modules ++ extraModules;
          buildFunctions = oldBuilds ++ extraBuildFunctions;
          aggregateFunctions = oldAggregates ++ extraAggregateFunctions;
          meta = lib.recursiveUpdate meta extraMeta;
          specialArgs = specialArgs // extraSpecialArgs;
        };
    };
in
{
  inherit mkBuilder;

  buildOutputsToAttrs =
    outs:
    builtins.foldl' lib.recursiveUpdate { } (
      map (
        {
          path,
          output,
        }:
        lib.setAttrByPath path output
      ) outs
    );

  callBuilders =
    inputs: flake: den:
    let
      builtOutputs = concatMap (
        builder:
        let
          discovered = concatMap (
            dir:
            attrValues (
              discoverGenerics {
                inherit inputs flake;
                baseMetas = builder.modules;
                inherit (builder) specialArgs;
              } dir
            )
          ) builder.searchPaths;
        in
        concatMap (
          targetCtx: mapAttrsToList (_: buildFn: buildFn targetCtx) builder.buildFunctions
        ) discovered
      ) (attrValues den.builders);

      aggregateOutputs = concatMap (
        builder: mapAttrsToList (_: aggFn: aggFn builtOutputs) builder.aggregateFunctions
      ) (attrValues den.builders);
    in
    foldl' lazyMerge { } (builtOutputs ++ aggregateOutputs);
}
