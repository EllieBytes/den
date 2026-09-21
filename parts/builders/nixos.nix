{ config, ... }:

let
  inherit (builtins) elem filter attrNames readDir;

  candidates = [
    "hosts"
    "nixos"
  ];

  filterCandidate = candidate:
    if config.den.root != null then
      if elem candidate (attrNames (readDir config.den.root)) then
        true
      else
        false
    else false;

  accepted =
    if config.den.root != null then
      (map (name: config.den.root + "/${name}")
        (filter filterCandidate candidates))
    else [];
in {
  config.den.builders.nixos = {
    name = "nixos";
    modules = [
      ../../modules/meta/nixos.nix
    ];
    searchPaths = accepted;
    buildFunctions = {
      system = { name, meta, path, specialArgs, ... }: {
        nixosConfigurations."${name}" =
          let
            inherit (builtins) pathExists;
          in meta.nixpkgs.nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            (if pathExists (path + "/configuration.nix") then (path + "/configuration.nix") else {})
          ];
          inherit specialArgs;
        };
      };
    };
  };
}
