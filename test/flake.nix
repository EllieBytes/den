{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    den.url = "github:EllieBytes/den";
  };

  outputs = inputs@{flake-parts, den, ...}:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ den.flakeModules.default ];

      den.searchPaths.packages = [
        ./pkgs
      ];

      den.searchPaths.nixos = [
        ./hosts
      ];

      den.searchPaths.home = [
        ./home
      ];

      den.searchPaths.builder = [
        ./builders
      ];
    };


}
