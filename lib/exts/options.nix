final: prev: {
  mkEnableOption' = name: default: final.mkOption {
    type = final.types.bool;
    inherit default;
    example = true;
    description = "Whether to enable ${name}";
  };

  # For short, undocumented stuff. Try not to use it unless it's really called for.
  mkOpt = type: default: final.mkOption {
    inherit type default;
  };

  mkOpt' = type: final.mkOption {
    inherit type;
  };
}
