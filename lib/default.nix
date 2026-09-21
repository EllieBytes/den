{ inputs ? {}, lib, exts ? [] }:

let
  extendMany = base: exts: base.pipe base (map (next: last: last.extend next) exts);
in lib.makeExtensible (self: lib.recursiveUpdate (extendMany lib exts) (({ inputs, lib }:
  let
    callLibrary = path: import path { inherit inputs; lib = self; };
  in rec {
    discovery = callLibrary ./discovery.nix;
    builder = callLibrary ./builder.nix;

    # Prelude.
    inherit (discovery) discoverGenerics discoverGenerics' discoverGeneric;
  }) { inherit inputs; lib = extendMany lib exts; }))

/*
rec {

  discovery = import ./discovery.nix { inherit inputs; lib = (lib.extend (import ./exts/files.nix)).extend (import ./exts/options.nix); };
  builder = import ./builder.nix { inherit inputs; lib = (lib.extend (import ./exts/files.nix)).extend (import ./exts/options.nix);};

  inherit (discovery) discoverGenerics discoverGenerics' discoverGeneric;
}
*/
