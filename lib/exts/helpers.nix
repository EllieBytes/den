_: _:
let
  inherit (builtins) pathExists isAttrs isList isNull isFunction mapAttrs;
in
rec {
  # Literally equivalent to (a: a)
  identity = a: a;

  safeImport = p: d: if pathExists p then import p else d;

  safeImport' = p: safeImport p null;

  # Sanitizes values recursively, making it exportable in json format.
  intoExportable = value:
    if isAttrs value then
      (mapAttrs (_: v: intoExportable v) value)
    else if isList value then
      (map intoExportable value)
    else if isNull value then
      ""
    else if isFunction value then
      "<function>"
    else value;
}
