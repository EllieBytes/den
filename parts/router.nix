{
  inputs,
  config,
  lib,
  ...
}:
let
  inherit (builtins)
    head
    mapAttrs
    unsafeDiscardStringContext
    replaceStrings
    ;
  inherit (lib) mkDefault attrNames;

  translateBuilder =
    name: builder:
    let
      normPath =
        str:
        let
          cleaned = replaceStrings [ "${inputs.self.outPath}/" "${inputs.self.outPath}" ] [ "./" "." ] str;
        in
        unsafeDiscardStringContext cleaned;

      defaultPath =
        if builder.searchPaths == [ ] then
          "(none)"
        else
          "${normPath (toString (head builder.searchPaths))}";
    in
    {
      inherit (builder) name;
      inherit (builder.meta) description authors;

      version = toString builder.meta.version;
      search_paths = map (p: normPath (toString p)) builder.searchPaths;
      build_functions = attrNames builder.buildFunctions;
      aggregate_functions = attrNames builder.aggregateFunctions;
      default_path = defaultPath;
      template_path = "${if isNull builder.meta.template then "" else toString builder.meta.template}";
    };
in
{
  flake.den = {
    builders = config.den.builders;
    internal.builders = mapAttrs translateBuilder config.den.builders;
    internal.default_template = toString ./default_template;
    internal.defaultPathMappings = mapAttrs (
      name:
      { searchPaths, ... }:
      mkDefault (head searchPaths)
    ) config.den.builders;
  };
}
