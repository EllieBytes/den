{
  config,
  denLib,
  ...
}: let
in {
  config.flake = denLib.builder.callBuilders config.den;
}
