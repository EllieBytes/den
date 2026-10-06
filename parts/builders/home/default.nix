{
  config,
  lib,
  denLib,
  ...
}:

let
  inherit (builtins) pathExists;
  inherit (lib) mkDefault;
  inherit (denLib) fs;
  inherit (fs) allPathsPresentIn;
in
{
  den.builders.home-manager = {
    name = "home-manager";
    searchPaths =
      if config.den.root != null then
        mkDefault (allPathsPresentIn [ "home" "homes" "users" "homeConfigurations" ] config.den.root)
      else
        [ ];

    modules = [
      ./modules
    ];

    buildFunctions.home =
      {
        name,
        meta,
        path,
        ...
      }:
      {
        homeConfigurations."${name}" = meta.home-manager.lib.homeManagerConfiguration {
          pkgs = if meta.pkgs == null then meta.nixpkgs.legacyPackages."${meta.system}" else meta.pkgs;
          modules = [
            (if pathExists (path + "/home.nix") then import (path + "/home.nix") else { })
            (if pathExists (path + "/default.nix") then import (path + "/default.nix") else { })
          ]
          ++ meta.extraModules;
        };
      };
  };
}
