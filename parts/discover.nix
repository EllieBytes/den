{ inputs, lib, config, ... }:

let
  inherit (builtins) foldl';
  inherit (lib.builder) callBuilder;
  searchPaths =
    let
      searchPathNames = builtins.attrNames config.den.searchPaths;
      validNames = foldl' (valid: current: if config.den.builders ? current then valid ++ [current] else valid) [] searchPathNames;
    in lib.attrsToList (map (name: { inherit name; value = config.den.searchPaths."${x}"; }) validNames);

  outs = lib.pipe searchPaths [
    (builtins.mapAttrs
      (name: value: map
        (callBuilder { inherit inputs config; } config.den.builders."${name}".builder)
      value)
    )
    lib.builder.mergeBuildOutputs
  ];
in { config = outs; }
