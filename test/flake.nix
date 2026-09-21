{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    den.url = "github:EllieBytes/den";
  };

  outputs = inputs@{flake-parts, den ...}:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ den.flakeModule ];

      den.builders.package.searchPaths = [
        ./pkgs
      ];

      den.builders.nixos.searchPaths = [
        ./hosts
      ];

      den.builders.home.searchPaths = [
        ./home
      ];

      den.builders.builder.searchPaths = [
        ./builders
      ];
    };


}
