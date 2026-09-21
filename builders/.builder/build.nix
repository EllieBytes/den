{ inputs, lib, name, path, meta, flake, ... }:

let
  callAggregate = path: outputs:
    import (path) { inherit outputs flake lib name path meta inputs; };
in
[
  {
    path = [ "flake" "den" "builders" "${name}" "builder" ];
    output = lib.builder.mkBuilder {
      inherit name;
      inherit (meta) meta;

      buildFunction = args:
        map (build: import build args) meta.builds;

      aggregateFunction =
        if pathExists (path + "/aggregate.nix") then
          callAggregate (path + "/aggregate.nix")
        else
          (_: []);
    };
  }
]
