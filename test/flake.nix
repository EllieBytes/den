{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    den.url = ./..;
  };

  outputs = inputs@{flake-parts, den, ...}:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.den.flakeModules.default ];

      den.root = ./.;
    };
}
