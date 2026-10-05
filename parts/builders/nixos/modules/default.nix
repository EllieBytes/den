{
  inputs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (types) nullOr listOf;
in
{
  imports = [
    ./agenix.nix
    ./disko.nix
    ./home-manager.nix
    ./deployment.nix
  ];

  options = {
    enable = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Whether to enable this host.
      '';
    };

    hostname = mkOption {
      type = types.str;
      default = "nixos";
    };

    system = mkOption {
      type = types.str;
      default = "x64_64-linux";
      example = "aarch64-linux";
    };

    extraModules = mkOption {
      type = listOf types.deferredModule;
      default = [ ];
    };

    nixpkgs = {
      nixpkgs = mkOption {
        type = nullOr types.raw;
        default = inputs.nixpkgs or null;
      };
    };
  };
}
