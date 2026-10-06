{
  inputs,
  config,
  denLib,
  ...
}:
let
in
{
  config.flake = denLib.builder.callBuilders inputs config.flake config.den;
}
