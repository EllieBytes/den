{
  denLib,
  lib,
  config,
  ...
}:

let
  inherit (builtins) foldl' pathExists;

  forEachSystem = systems: functor: foldl' denLib.lazyMerge { } (map functor systems);
in
{
  den.builders.package = {
    name = "package";
    modules = [
      ./modules
    ];

    searchPaths =
      if config.den.root != null then
        denLib.fs.allPathsPresentIn [ "packages" "pkgs" ] config.den.root
      else
        [ ];

    buildFunctions.package =
      {
        name,
        path,
        meta,
        ...
      }:
      {
        packages = forEachSystem meta.systems (system: {
          "${system}"."${name}" =
            let
              pkgs = meta.nixpkgs.legacyPackages."${system}";

              pkg =
                if meta.entrypoint == null then
                  if pathExists (path + "/package.nix") then (path + "/package.nix") else (path + "/default.nix")
                else
                  meta.entrypoint;
            in
            pkgs.callPackage pkg meta.args;
        });
      };

    meta = {
      version = "0.1.0-alpha";
      template = ./template;
      authors = [ "Ellie Johnston <jelli7118@proton.me>" ];
      description = ''
        Creates a package.

        package => packages.<system>.<name>
      '';
    };
  };
}
