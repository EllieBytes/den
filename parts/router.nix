{ config, ... }:

{
  flake.den = {
    builders = config.den.builders;
  };
}
