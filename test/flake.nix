{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    den.url = ./..;
    nix-unit.url = "github:nix-community/nix-unit";
  };

  outputs =
    inputs@{
      flake-parts,
      den,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.nix-unit.modules.flake.default
        inputs.den.flakeModules.default
      ];

      den.root = ./.;

      perSystem =
        {
          config,
          pkgs,
          ...
        }:
        {
          nix-unit.tests = {
            "nixos_structural" = {
              expr = builtins.attrNames config.flake.nixosConfigurations;
              expected = [
                "test"
                "test-b"
              ];
            };

            "nixos_built" = {
              expr =
                let
                  built = config.flake.nixosConfigurations.test;
                in
                {
                  hostName = built.config.networking.hostName;
                  user = built.config.users.users ? "test";
                };

              expected = {
                hostName = "test-system.local";
                user = true;
              };
            };
          };
        };
    };
}
