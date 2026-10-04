{
  config,
  lib,
  ...
}:
let
  inherit (builtins) head mapAttrs;
  inherit (lib) mkDefault;
in
{
  flake.den = {
    builders = config.den.builders;

    internal.defaultPathMappings = mapAttrs (
      name:
      { searchPaths, ... }:
      mkDefault (head searchPaths)
    ) config.den.builders;
  };
}
