{ config, denLib, ... }:

let
in {
  config.flake = denLib.callBuilders config.den;
}
