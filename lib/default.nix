{ inputs ? {}, lib ? (import <nixpkgs>).lib, exts ? [] }:

let
  extendMany = base: exts: base.pipe base (map (next: last: last.extend next) exts);
in lib.makeExtensible (self: lib.recursiveUpdate (extendMany lib exts) (({ inputs, lib }:
  let
    callLibrary = self: path: import path { inherit inputs; lib = self; };
  in rec {
    discovery = callLibrary self ./discovery.nix;
    builder = callLibrary self ./builder.nix;

    # Prelude.
    inherit (discovery) discoverGenerics discoverGenerics' discoverGeneric;
  }) { inherit inputs; lib = extendMany lib exts; }))
